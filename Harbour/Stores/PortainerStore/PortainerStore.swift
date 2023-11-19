//
//  PortainerStore.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

// swiftlint:disable file_length

import Combine
import CommonFoundation
import CommonOSLog
import KeychainKit
import OSLog
import PortainerKit
import SwiftData

// MARK: - PortainerStore

/// Main store for Portainer-related data.
public final class PortainerStore: ObservableObject, @unchecked Sendable {

	/// Singleton for `PortainerStore`
	static let shared = PortainerStore()

	// MARK: Private properties

	private let logger = Logger(.custom(PortainerStore.self))
	private let keychain = Keychain.shared
	private let preferences = Preferences.shared
	private let portainer: Portainer

	// MARK: Public properties

	/// Currently selected server URL
	public var serverURL: URL? {
		portainer.serverURL
	}

	/// URLs with stored tokens
	public var savedURLs: [URL] {
		(try? keychain.getSavedURLs()) ?? []
	}

	/// Task for `PortainerStore` setup
	public private(set) var setupTask: Task<Void, Never>?

	/// Task for `endpoints` refresh
	public private(set) var endpointsTask: Task<[Endpoint], Error>?

	/// Task for `containers` refresh
	public private(set) var containersTask: Task<[Container], Error>?

	/// Is `PortainerStore` setup?
	@Published
	private(set) var isSetup = false

	/// Currently selected endpoint's ID
	@Published
	private(set) var selectedEndpoint: Endpoint? {
		didSet { onSelectedEndpointChange(selectedEndpoint) }
	}

	/// Endpoints
	@Published
	private(set) var endpoints: [Endpoint] = [] {
		didSet { onEndpointsChange(endpoints) }
	}

	/// Containers
	@Published
	private(set) var containers: [Container] = []

	// MARK: init

	/// Initializes `PortainerStore` with provided URLSession configuration.
	/// - Parameter urlSessionConfiguration: `URLSessionConfiguration`, `.default` if none provided.
	init(urlSessionConfiguration: URLSessionConfiguration = .default) {
//		urlSessionConfiguration.shouldUseExtendedBackgroundIdleMode = true
//		urlSessionConfiguration.sessionSendsLaunchEvents = true
		self.portainer = Portainer(urlSessionConfiguration: urlSessionConfiguration)

		self.selectedEndpoint = getStoredEndpoint()

		if let (url, token) = getStoredCredentials() {
			self.setupTask = Task { @MainActor in
				try? await setup(url: url, token: token, saveToken: false, _refresh: false)
			}
		} else {
			Task { @MainActor in
				endpoints = []
				containers = []
			}
		}
	}
}

// MARK: PortainerStore+State

public extension PortainerStore {
	/// Sets up Portainer with provided credentials.
	/// - Parameters:
	///   - url: Server URL
	///   - token: Authorization token (if `nil`, it's searched in the keychain)
	///   - saveToken: Should the token be saved to the keychain?
	@Sendable @MainActor
	func setup(url: URL, token: String?, saveToken: Bool = true, _refresh: Bool = true) async throws {
		logger.notice("Setting up, URL: \(url.absoluteString, privacy: .sensitive(mask: .hash))... [\(String._debugInfo(), privacy: .public)]")

		do {
			isSetup = false

			let _token = try (token ?? keychain.getString(for: url))
			portainer.setup(url: url, token: _token)

			preferences.selectedServer = url.absoluteString

			if _refresh {
				let refreshTask = refresh(_awaitSetup: false)
				_ = try await refreshTask.value
			}

			if saveToken {
				do {
					try keychain.setString(_token, for: url, itemDescription: Keychain.tokenItemDescription)
				} catch {
					logger.error("Unable to save token to Keychain: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
				}
			}

			isSetup = true

			logger.debug("Setup with URL: \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\" sucessfully! [\(String._debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to setup: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Switches server to provided `serverURL`.
	/// - Parameter serverURL: Server URL to switch to
	func switchServer(to serverURL: URL) async throws {
		logger.notice("Switching to \"\(serverURL.absoluteString, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")

		preferences.selectedServer = serverURL.absoluteString

		do {
			let token = try keychain.getString(for: serverURL)

//			reset()

			try await setup(url: serverURL, token: token, saveToken: false)

			logger.debug("Switched successfully! [\(String._debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to switch: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Removes authorization data from Keychain for the provided server URL.
	/// - Parameter serverURL: Server URL to remove data for
	func removeServer(_ serverURL: URL) throws {
		logger.notice("Removing token for url: \"\(serverURL.absoluteString, privacy: .sensitive(mask: .hash))\" [\(String._debugInfo(), privacy: .public)]")
		do {
			try keychain.removeContent(for: serverURL)
			logger.debug("Removed token successfully! [\(String._debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to remove token: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Resets `PortainerStore` state.
	@MainActor
	func reset() {
		logger.notice("Resetting state [\(String._debugInfo(), privacy: .public)]")

		portainer.reset()

		isSetup = false

		preferences.selectedEndpoint = nil
		preferences.selectedServer = nil

		endpointsTask?.cancel()
		endpoints = []

		containersTask?.cancel()
		containers = []
		storeContainers([])
	}

	/// Selects the currently active endpoint.
	/// - Parameter endpoint: Endpoint to switch to
	@MainActor
	func selectEndpoint(_ endpoint: Endpoint?) {
		// swiftlint:disable:next line_length
		logger.notice("Selected endpoint: \"\(endpoint?.name ?? "<none>", privacy: .sensitive(mask: .hash))\" (\(endpoint?.id.description ?? "<none>")) [\(String._debugInfo(), privacy: .public)]")
		self.selectedEndpoint = endpoint

		if endpoint != nil {
			refreshContainers()
		} else {
			containersTask?.cancel()
			containersTask = nil
			containers = []
			storeContainers([])
		}
	}
}

// MARK: - PortainerStore+General

public extension PortainerStore {
	@Sendable
	func fetchEndpoints() async throws -> [Endpoint] {
		logger.info("Getting endpoints... [\(String._debugInfo(), privacy: .public)]")
		do {
			let endpoints = try await portainer.fetchEndpoints()
			logger.debug("Got \(endpoints.count, privacy: .public) endpoints [\(String._debugInfo(), privacy: .public)]")
			return endpoints.sorted()
		} catch {
			logger.error("Failed to get endpoints: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@Sendable
	func fetchContainers(filters: Portainer.FetchFilters? = nil) async throws -> [Container] {
		logger.info("Getting containers... (filters: \(String(describing: filters), privacy: .sensitive(mask: .hash))) [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			let containers = try await portainer.fetchContainers(endpointID: endpoint.id, filters: filters)
			logger.debug("Got \(containers.count, privacy: .public) containers [\(String._debugInfo(), privacy: .public)]")
			return containers.sorted()
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Fetches all of the containers belonging to specified stack name.
	/// - Parameter stackName: Stack name
	/// - Returns: Array of containers
	@Sendable
	func getContainers(for stackName: String) async throws -> [Container] {
		logger.info("Getting containers for stack \"\(stackName, privacy: .sensitive(mask: .hash))\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			let containers = try await portainer.fetchContainers(endpointID: endpoint.id, stackName: stackName)
			logger.debug("Got \(containers.count, privacy: .public) containers [\(String._debugInfo(), privacy: .public)]")
			return containers.sorted()
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Fetches the details for the provided container ID.
	/// - Parameters:
	///   - containerID: ID of the inspected container
	///   - endpointID: ID of the endpoint
	/// - Returns: `ContainerDetails`
	@Sendable
	func inspectContainer(_ containerID: Container.ID, endpointID: Endpoint.ID? = nil) async throws -> ContainerDetails {
		logger.info("Getting details for containerID: \"\(containerID, privacy: .private(mask: .hash))\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			guard portainer.isSetup else {
				throw PortainerError.notSetup
			}
			guard let endpointID = endpointID ?? selectedEndpoint?.id else {
				throw PortainerError.noSelectedEndpoint
			}
			let details = try await portainer.inspectContainer(containerID, endpointID: endpointID)
			logger.debug("Got details for containerID: \"\(containerID, privacy: .private(mask: .hash))\" [\(String._debugInfo(), privacy: .public)]")
			return details
		} catch {
			logger.error("Failed to get container details: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Fetches the logs for the provided container ID.
	/// - Parameters:
	///   - containerID: ID of the selected container
	///   - logsSince: `TimeInterval` for how old logs we want to fetch
	///   - lastEntriesAmount: Amount of last log lines
	///   - includeTimestamps: Include timestamps?
	/// - Returns: Logs of the container
	@Sendable
	func getLogs(
		for containerID: Container.ID,
		since logsSince: TimeInterval = 0,
		tail lastEntriesAmount: Int = 100,
		timestamps includeTimestamps: Bool = false
	) async throws -> String {
		logger.info("Getting logs for containerID: \"\(containerID, privacy: .public)\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			let logs = try await portainer.fetchLogs(containerID: containerID,
													 endpointID: endpoint.id,
													 since: logsSince,
													 tail: lastEntriesAmount,
													 timestamps: includeTimestamps)
			// TODO: https://github.com/portainer/portainer/blob/develop/app/docker/helpers/logHelper/formatLogs.ts

			logger.debug("Got logs for containerID: \"\(containerID, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")

			return logs
		} catch {
			logger.error("Failed to get logs for containerID: \"\(containerID, privacy: .public)\": \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Executes the provided action on selected container ID.
	/// - Parameters:
	///   - action: Action to execute
	///   - containerID: ID of the container we want to execute the action on.
	@Sendable
	func execute(_ action: ExecuteAction, on containerID: Container.ID) async throws {
		// swiftlint:disable:next line_length
		logger.notice("Executing action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			try await portainer.execute(action, containerID: containerID, endpointID: endpoint.id)

			Task { @MainActor in
				if let storedContainerIndex = containers.firstIndex(where: { $0.id == containerID }) {
					containers[storedContainerIndex].state = action.expectedState
				}
			}

			logger.debug("Executed action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")
		} catch {
			// swiftlint:disable:next line_length
			logger.error("Failed to execute action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\": \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}
}

// MARK: - PortainerStore+Stacks

extension PortainerStore {
	/// Fetches all of the stacks.
	/// - Returns: `[Stack]`
	@Sendable
	func getStacks() async throws -> [Stack] {
		logger.info("Getting stacks... [\(String._debugInfo(), privacy: .public)]")
		do {
			let stacks = try await portainer.fetchStacks()
			logger.debug("Got \(stacks.count, privacy: .public) stacks [\(String._debugInfo(), privacy: .public)]")
			return stacks.sorted()
		} catch {
			logger.error("Failed to get stacks: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	/// Sets stack status (started/stopped) for provided stack ID.
	/// - Parameters:
	///   - stackID: Stack ID to start/stop
	///   - started: Should stack be started?
	/// - Returns: `Stack`
	@Sendable @discardableResult
	func setStackStatus(stackID: Stack.ID, started: Bool) async throws -> Stack {
		logger.notice("\(started ? "Starting" : "Stopping", privacy: .public) stack with ID: \(stackID)... [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			let stack = try await portainer.setStackStatus(endpointID: endpoint.id, stackID: stackID, started: started)
			logger.debug("\(started ? "Started" : "Stopped", privacy: .public) stack with ID: \(stackID) [\(String._debugInfo(), privacy: .public)]")
			return stack
		} catch {
			logger.error("Failed to \(started ? "start" : "stop", privacy: .public) stack with ID: \(stackID): \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}
}

// MARK: - PortainerStore+Refresh

extension PortainerStore {
	/// Refreshes endpoints and containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `ErrorHandler` used to notify the user of errors.
	/// - Returns: `Task<Void, Error>` of refresh.
	@discardableResult
	func refresh(errorHandler: ErrorHandler? = nil,
				 _awaitSetup: Bool = true,
				 _debugInfo: String = ._debugInfo()) -> Task<([Endpoint], [Container]?), Error> {
		let task = Task { @MainActor in
			do {
				if _awaitSetup {
					await setupTask?.value
				}

				let endpointsTask = refreshEndpoints(errorHandler: errorHandler, _debugInfo: _debugInfo)
				let endpoints = try await endpointsTask.value

				let containers: [Container]?
				if selectedEndpoint != nil {
					let containersTask = refreshContainers(errorHandler: errorHandler, _debugInfo: _debugInfo)
					containers = try await containersTask.value
				} else {
					containers = nil
				}

				return (endpoints, containers)
			} catch {
				errorHandler?(error, _debugInfo)
				throw error
			}
		}
		return task
	}

	/// Refreshes endpoints, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `ErrorHandler` used to notify the user of errors.
	/// - Returns: `Task<[Endpoint], Error>` of refresh.
	@discardableResult
	func refreshEndpoints(errorHandler: ErrorHandler? = nil, _debugInfo: String = ._debugInfo()) -> Task<[Endpoint], Error> {
		endpointsTask?.cancel()
		let task = Task<[Endpoint], Error> { @MainActor in
			do {
				let endpoints = try await fetchEndpoints()
				self.endpoints = endpoints
				return endpoints
			} catch {
				if error.isCancellationError { return self.endpoints }
				errorHandler?(error, _debugInfo)
				throw error
			}
		}
		endpointsTask = task
		return task
	}

	/// Refreshes containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `ErrorHandler` used to notify the user of errors.
	/// - Returns: `Task<[Container], Error>` of refresh.
	@discardableResult
	func refreshContainers(errorHandler: ErrorHandler? = nil, _debugInfo: String = ._debugInfo()) -> Task<[Container], Error> {
		containersTask?.cancel()
		let task = Task<[Container], Error> { @MainActor in
			do {
				let containers = try await fetchContainers()
				self.containers = containers
				storeContainers(containers)

				return containers
			} catch {
				if error.isCancellationError { return self.containers }
				errorHandler?(error, _debugInfo)
				throw error
			}
		}
		containersTask = task
		return task
	}
}

// MARK: - PortainerStore+Helpers

private extension PortainerStore {
	/// Checks if `portainer` is setup, unwraps `selectedEndpoint`, returns both, or throws an error if there's none.
	/// - Returns: Unwrapped `(Portainer, Endpoint)`
	func getPortainerAndEndpoint() throws -> (Portainer, Endpoint) {
		guard portainer.isSetup else {
			throw PortainerError.notSetup
		}
		guard let selectedEndpoint else {
			throw PortainerError.noSelectedEndpoint
		}
		return (portainer, selectedEndpoint)
	}
}

// MARK: - PortainerStore+OnDidChange

private extension PortainerStore {
	func onSelectedEndpointChange(_ selectedEndpoint: Endpoint?) {
		Task { @MainActor in
			guard let selectedEndpoint else {
				preferences.selectedEndpoint = nil
				return
			}
			preferences.selectedEndpoint = StoredEndpoint(id: selectedEndpoint.id, name: selectedEndpoint.name)
		}
	}

	func onEndpointsChange(_ endpoints: [Endpoint]) {
		Task { @MainActor in
			if endpoints.isEmpty {
				containers = []
				selectedEndpoint = nil
				storeContainers([])
			} else if endpoints.count == 1 {
				selectedEndpoint = endpoints.first
			} else {
				selectedEndpoint = endpoints.first(where: { $0.id == preferences.selectedEndpoint?.id })
			}
		}
	}

	func onContainersChange(_ containers: [Container]) {
		storeContainers(containers)
	}
}

// MARK: - PortainerStore+Persistence

extension PortainerStore {
	@MainActor
	func loadStoredContainersIfNeeded() {
		if let storedContainers = loadStoredContainers(),
		   !self.containers.contains(where: { !$0._isStored }) {
			self.containers = storedContainers
		}
	}

	/// Loads authorization token for saved server if available.
	/// - Returns: Credentials for Portainer
	private func getStoredCredentials() -> (url: URL, token: String)? {
		logger.debug("Looking for credentials... [\(String._debugInfo(), privacy: .public)]")
		do {
			guard let selectedServer = preferences.selectedServer,
				  let selectedServerURL = URL(string: selectedServer) else {
				logger.warning("No selected server [\(String._debugInfo(), privacy: .public)]")
				return nil
			}

			let token = try keychain.getString(for: selectedServerURL)
			logger.debug("Got token for URL: \"\(selectedServerURL.absoluteString, privacy: .sensitive(mask: .hash))\" [\(String._debugInfo(), privacy: .public)]")
			return (selectedServerURL, token)
		} catch {
			logger.warning("Failed to load token: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			return nil
		}
	}

	/// Loads stored selected endpoint if available.
	/// - Returns: `Endpoint` if anything is stored, `nil` otherwise.
	private func getStoredEndpoint() -> Endpoint? {
		guard let storedEndpoint = preferences.selectedEndpoint else { return nil }
		return Endpoint(id: storedEndpoint.id, name: storedEndpoint.name)
	}

	/// Stores containers to SwiftData.
	/// - Parameter containers: Containers to store
	private func storeContainers(_ containers: [Container]) {
		logger.debug("Storing \(containers.count, privacy: .public) containers... [\(String._debugInfo(), privacy: .public)]")

		Task { @MainActor in
			do {
				let model = try ModelContainer(for: StoredContainer.self)
				let containerIDs = Set(containers.map(\.id))

				let nonExistingContainersPredicate = #Predicate<StoredContainer> {
					!containerIDs.contains($0.id)
				}
				try model.mainContext.delete(model: StoredContainer.self, where: nonExistingContainersPredicate)

				for container in containers {
					let storedContainer = StoredContainer(container: container)
					model.mainContext.insert(storedContainer)
				}

				try model.mainContext.save()

				logger.debug("Stored \(containers.count, privacy: .public) containers. [\(String._debugInfo(), privacy: .public)]")
			} catch {
				logger.error("Failed to store containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			}
		}
	}

	/// Fetches stored containers and returns them.
	/// - Returns: Mapped [Container] from SwiftData.
	@MainActor
	private func loadStoredContainers() -> [Container]? {
		logger.debug("Loading stored containers... [\(String._debugInfo(), privacy: .public)]")

		do {
			let model = try ModelContainer(for: StoredContainer.self)

			var descriptor = FetchDescriptor<StoredContainer>()
			descriptor.sortBy = [.init(\.name)]

			let items = try model.mainContext.fetch(descriptor)

			logger.info("Got \(items.count, privacy: .public) stored containers. [\(String._debugInfo(), privacy: .public)]")

			return items.map { .init(storedContainer: $0) }
		} catch {
			logger.error("Failed to load stored containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			return nil
		}
	}
}
