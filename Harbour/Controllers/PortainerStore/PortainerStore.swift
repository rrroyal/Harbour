//
//  PortainerStore.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import Foundation
import OSLog
import CoreData
import PortainerKit
import KeychainKit
import CommonFoundation
import CommonCoreData
import CommonOSLog

// TODO: Split this file

// MARK: - PortainerStore

/// Main store for Portainer-related data.
public final class PortainerStore: ObservableObject {

	/// Singleton for `PortainerStore`
	static let shared = PortainerStore()

	// MARK: Private properties

	private let logger = Logger(category: Logger.Category.portainerStore)
	// swiftlint:disable:next force_unwrapping
	private let keychain = Keychain(accessGroup: Bundle.main.groupIdentifier!)
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
	@Published private(set) var isSetup = false

	/// Currently selected endpoint's ID
	@Published private(set) var selectedEndpoint: Endpoint? {
		didSet { onSelectedEndpointChange(selectedEndpoint) }
	}

	/// Endpoints
	@Published private(set) var endpoints: [Endpoint] = [] {
		didSet { onEndpointsChange(endpoints) }
	}

	/// Containers of `selectedEndpoint`
	@Published private(set) var containers: [Container] = [] {
		didSet { onContainersChange(containers) }
	}

	// MARK: init

	init(urlSessionConfiguration: URLSessionConfiguration = .default) {
//		urlSessionConfiguration.shouldUseExtendedBackgroundIdleMode = true
//		urlSessionConfiguration.sessionSendsLaunchEvents = true
		portainer = Portainer(urlSessionConfiguration: urlSessionConfiguration)

		self.selectedEndpoint = getStoredEndpoint()

		if let (url, token) = getStoredCredentials() {
			portainer.setup(url: url, token: token)
			self.setupTask = Task { @MainActor in
				let storedContainers = loadStoredContainers()
				if self.containers.isEmpty {
					self.containers = storedContainers
				}
			}
		} else {
			endpoints = []
			containers = []
		}
	}

	// MARK: Public Functions

	@Sendable @MainActor
	/// Sets up Portainer with provided credentials.
	/// - Parameters:
	///   - url: Server URL
	///   - token: Authorization token (if `nil`, it's searched in the keychain)
	public func setup(url: URL, token: String?) async throws {
		logger.notice("Setting up, URL: \(url.absoluteString, privacy: .sensitive(mask: .hash))... [\(String._debugInfo(), privacy: .public)]")

		do {
			isSetup = false

			let _token: String
			if let token {
				_token = token
			} else {
				_token = try keychain.getContent(for: url)
			}

			portainer.setup(url: url, token: _token)

//			logger.debug("Getting endpoints for setup... [\(String._debugInfo(), privacy: .public)]")

//			let endpointsTask = refreshEndpoints()
//			_ = try await endpointsTask.value

			// Check if authorized
			let refreshTask = refresh()
			_ = try await refreshTask.value

//			let endpoints = try await portainer.fetchEndpoints()
//			logger.debug("Got \(endpoints.count, privacy: .public) endpoints [\(String._debugInfo(), privacy: .public)]")
//			self.endpoints = endpoints

			isSetup = true

			preferences.selectedServer = url.absoluteString

			do {
				try keychain.saveContent(_token, for: url)
			} catch {
				logger.error("Unable to save token to Keychain: \(error.localizedDescription, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			}

			logger.info("Setup with URL: \"\(url.absoluteString, privacy: .sensitive)\" sucessfully! [\(String._debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to setup: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@MainActor
	public func switchServer(to serverURL: URL) async throws {
		logger.notice("Switching to \"\(serverURL.absoluteString, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")

		preferences.selectedServer = serverURL.absoluteString

		do {
			let token = try keychain.getContent(for: serverURL)

			isSetup = false
			preferences.selectedServer = nil

			endpointsTask?.cancel()
			endpoints = []

			containersTask?.cancel()
			containers = []

			try await setup(url: serverURL, token: token)

			logger.info("Switched successfully! [\(String._debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to switch: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	public func deleteServer(_ serverURL: URL) throws {
		logger.notice("Removing token for serverURL: \(serverURL.absoluteString, privacy: .sensitive) [\(String._debugInfo(), privacy: .public)]")
		do {
			try keychain.removeContent(for: serverURL)
			logger.info("Removed token successfully! [\(String._debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to remove token: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@MainActor
	public func selectEndpoint(_ endpoint: Endpoint?) {
		logger.notice("Selected endpoint: \"\(endpoint?.name ?? "<none>", privacy: .sensitive)\" (\(endpoint?.id.description ?? "<none>")) [\(String._debugInfo(), privacy: .public)]")
		self.selectedEndpoint = endpoint

		if endpoint != nil {
			refreshContainers()
		} else {
			containersTask?.cancel()
			containersTask = nil
			containers = []
		}
	}

	@Sendable
	public func inspectContainer(_ containerID: Container.ID, endpointID: Endpoint.ID? = nil) async throws -> ContainerDetails {
		logger.notice("Getting details for containerID: \"\(containerID, privacy: .public)\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			guard portainer.isSetup else {
				throw PortainerError.notSetup
			}
			guard let endpointID = endpointID ?? selectedEndpoint?.id else {
				throw PortainerError.noSelectedEndpoint
			}
			let details = try await portainer.inspectContainer(containerID, endpointID: endpointID)
			logger.debug("Got details for containerID: \(containerID, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			return details
		} catch {
			logger.error("Failed to get container details: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@Sendable
	public func getLogs(for containerID: Container.ID) async throws -> String {
		logger.notice("Getting logs for containerID: \"\(containerID, privacy: .public)\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			let logs = try await portainer.fetchLogs(containerID: containerID, endpointID: endpoint.id)

			logger.debug("Got logs for containerID: \"\(containerID, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")

			return logs
		} catch {
			logger.error("Failed to get logs for containerID: \"\(containerID, privacy: .public)\": \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@Sendable
	public func execute(_ action: ExecuteAction, on containerID: Container.ID) async throws {
		// swiftlint:disable:next line_length
		logger.notice("Executing action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			try await portainer.execute(action, containerID: containerID, endpointID: endpoint.id)

//			if let storedContainerIndex = containers.firstIndex(where: { $0.id == containerID }) {
//				containers[storedContainerIndex].state = action.expectedState
//			}

			logger.debug("Executed action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")
		} catch {
			// swiftlint:disable:next line_length
			logger.error("Failed to execute action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\": \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

}

// MARK: - PortainerStore+Refresh

extension PortainerStore {

	@discardableResult @MainActor
	/// Refreshes endpoints and containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `SceneDelegate.ErrorHandler` used to notify the user of errors
	/// - Returns: `Task<Void, Error>` of refresh
	func refresh(errorHandler: SceneDelegate.ErrorHandler? = nil, _debugInfo: String = ._debugInfo()) -> Task<Void, Error> {
		let task = Task {
			do {
				await setupTask?.value

				let endpointsTask = refreshEndpoints(errorHandler: errorHandler, _debugInfo: _debugInfo)
				_ = try await endpointsTask.value
				if selectedEndpoint != nil {
					let containersTask = refreshContainers(errorHandler: errorHandler, _debugInfo: _debugInfo)
					_ = try await containersTask.value
				}
			} catch {
				errorHandler?(error, _debugInfo)
				throw error
			}
		}
		return task
	}

	@discardableResult @MainActor
	/// Refreshes endpoints, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `SceneDelegate.ErrorHandler` used to notify the user of errors
	/// - Returns: `Task<[Endpoint], Error>` of refresh
	func refreshEndpoints(errorHandler: SceneDelegate.ErrorHandler? = nil, _debugInfo: String = ._debugInfo()) -> Task<[Endpoint], Error> {
		endpointsTask?.cancel()
		let task = Task<[Endpoint], Error> {
			do {
				let endpoints = try await getEndpoints()
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

	@discardableResult @MainActor
	/// Refreshes containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `SceneDelegate.ErrorHandler` used to notify the user of errors
	/// - Returns: `Task<[Container], Error>` of refresh
	func refreshContainers(errorHandler: SceneDelegate.ErrorHandler? = nil, _debugInfo: String = ._debugInfo()) -> Task<[Container], Error> {
		containersTask?.cancel()
		let task = Task<[Container], Error> { [self] in
			do {
				let containers = try await getContainers()
				self.containers = containers
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

// MARK: - PortainerStore+Private

private extension PortainerStore {

	@Sendable
	func getEndpoints() async throws -> [Endpoint] {
		logger.notice("Getting endpoints... [\(String._debugInfo(), privacy: .public)]")
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
	func getContainers() async throws -> [Container] {
		logger.notice("Getting containers... [\(String._debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpoint) = try getPortainerAndEndpoint()
			let containers = try await portainer.fetchContainers(endpointID: endpoint.id)
			logger.debug("Got \(containers.count, privacy: .public) containers [\(String._debugInfo(), privacy: .public)]")
			return containers.sorted()
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
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
		guard let selectedEndpoint else {
			preferences.selectedEndpoint = nil
			return
		}
		preferences.selectedEndpoint = StoredEndpoint(id: selectedEndpoint.id, name: selectedEndpoint.name)
	}

	func onEndpointsChange(_ endpoints: [Endpoint]) {
		if endpoints.isEmpty {
			containers = []
			selectedEndpoint = nil
		} else if endpoints.count == 1 {
			selectedEndpoint = endpoints.first
		} else {
			selectedEndpoint = endpoints.first(where: { $0.id == preferences.selectedEndpoint?.id })
		}
	}

	func onContainersChange(_ containers: [Container]) {
		storeContainers(containers)
	}

}

// MARK: - PortainerStore+Persistence

private extension PortainerStore {

	/// Loads authorization token for saved server if available.
	/// - Returns: Credentials for Portainer
	func getStoredCredentials() -> (url: URL, token: String)? {
		logger.info("Looking for credentials... [\(String._debugInfo(), privacy: .public)]")
		do {
			guard let selectedServer = preferences.selectedServer,
				  let selectedServerURL = URL(string: selectedServer) else {
				logger.warning("No selected server [\(String._debugInfo(), privacy: .public)]")
				return nil
			}

			let token = try keychain.getContent(for: selectedServerURL)
			logger.info("Got token for URL: \"\(selectedServerURL.absoluteString, privacy: .sensitive(mask: .hash))\" [\(String._debugInfo(), privacy: .public)]")
			return (selectedServerURL, token)
		} catch {
			logger.warning("Failed to load token: \(error.localizedDescription, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			return nil
		}
	}

	/// Loads stored selected endpoint if available.
	/// - Returns: `Endpoint` if anything is stored, `nil` otherwise.
	func getStoredEndpoint() -> Endpoint? {
		guard let storedEndpoint = preferences.selectedEndpoint else { return nil }
		return Endpoint(id: storedEndpoint.id, name: storedEndpoint.name)
	}

	/// Stores containers to CoreData store.
	/// - Parameter containers: Containers to store
	func storeContainers(_ containers: [Container]) {
		logger.info("Saving \(containers.count, privacy: .public) containers... [\(String._debugInfo(), privacy: .public)]")

		do {
			let newContainersIDs = containers.map(\.id)

			let context = Persistence.shared.backgroundContext

			let fetchRequestToDelete: NSFetchRequest<NSFetchRequestResult> = StoredContainer.fetchRequest()
			fetchRequestToDelete.predicate = NSPredicate(format: "NOT (id IN %@)", newContainersIDs)

			let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestToDelete)
			_ = try? context.execute(deleteRequest)

			containers.forEach { container in
				let storedContainer = StoredContainer(context: context)
				storedContainer.id = container.id
				storedContainer.name = container.displayName
				storedContainer.lastState = container.state?.rawValue
			}

			let didSave = try context.saveIfNeeded()
			logger.debug("Inserted \(self.containers.count, privacy: .public) containers, needed to save: \(didSave, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to store containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		}
	}

	/// Fetches stored containers and returns them.
	/// - Returns: Mapped [Container] from CoreData store.
	func loadStoredContainers() -> [Container] {
		logger.info("Loading stored containers... [\(String._debugInfo(), privacy: .public)]")

		do {
			let context = Persistence.shared.backgroundContext
			let fetchRequest = StoredContainer.fetchRequest()
			let storedContainers = try context.fetch(fetchRequest)
			let containers = storedContainers
				.map {
					let names: [String]?
					if let name = $0.name {
						names = [name]
					} else {
						names = nil
					}
					return Container(id: $0.id ?? "", names: names, state: ContainerState(rawValue: $0.lastState ?? ""))
				}
				.sorted()

			logger.debug("Loaded \(containers.count, privacy: .public) containers [\(String._debugInfo(), privacy: .public)]")
			return containers
		} catch {
			logger.warning("Failed to fetch stored containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			return []
		}
	}

}
