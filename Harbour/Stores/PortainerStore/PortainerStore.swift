//
//  PortainerStore.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import Foundation
import os.log
import PortainerKit
import KeychainKit

// MARK: - PortainerStore

/// Main store for Portainer-related data.
final class PortainerStore: ObservableObject {

	/// Singleton for `PortainerStore`
	static let shared: PortainerStore = PortainerStore()

	// MARK: Private properties

	// swiftlint:disable:next force_unwrapping
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PortainerStore")
	internal let keychain: Keychain = Keychain(accessGroup: Bundle.main.groupIdentifier)

	internal var portainer: Portainer?

	// MARK: Public properties

	/// Server URL
	public var serverURL: URL? {
		portainer?.url
	}

	/// Task for `PortainerStore` setup
	public private(set) var setupTask: Task<Void, Never>?

	/// Task for `endpoints` refresh
	public private(set) var endpointsTask: Task<Void, Error>?

	/// Task for `containers` refresh
	public private(set) var containersTask: Task<Void, Error>?

	/// Is `PortainerStore` setup?
	@Published private(set) var isSetup: Bool = false

	/// Currently selected endpoint's ID
	@Published private(set) var selectedEndpointID: Endpoint.ID? = Preferences.shared.selectedEndpointID {
		didSet { onSelectedEndpointIDChange(selectedEndpointID) }
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

	private init() {
		logger.info("Initialized, loading stored containers... [\(String.debugInfo(), privacy: .public)]")
		setupIfStored()
		setupTask = Task { @MainActor in
			let storedContainers = loadStoredContainers()
			if containers.isEmpty {
				self.containers = storedContainers
			}

			setupTask?.cancel()
		}
	}

	// MARK: Public Functions

	@Sendable
	public func login(url: URL, token: String) async throws {
		logger.info("Setting up, URL: \(url.absoluteString, privacy: .sensitive(mask: .hash))... [\(String.debugInfo(), privacy: .public)]")

		do {
			isSetup = false

			let portainer = Portainer(url: url, token: token)

			logger.debug("Getting endpoints for setup... [\(String.debugInfo(), privacy: .public)]")
			let endpoints = try await portainer.fetchEndpoints()
			logger.debug("Got \(endpoints.count, privacy: .public) endpoints. [\(String.debugInfo(), privacy: .public)]")

			isSetup = true
			self.portainer = portainer
			self.endpoints = endpoints

			Preferences.shared.selectedServer = url.absoluteString

			do {
				try keychain.saveToken(for: url, token: token)
			} catch {
				logger.error("Unable to save token to Keychain: \(String(describing: error), privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			}

			logger.notice("Setup with URL: \"\(url.absoluteString, privacy: .sensitive)\" sucessfully! [\(String.debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to setup: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@MainActor
	public func selectEndpoint(_ endpoint: Endpoint?) {
		logger.info("Selected endpoint: \"\(endpoint?.name ?? "<none>", privacy: .sensitive)\" (\(endpoint?.id.description ?? "<none>")) [\(String.debugInfo(), privacy: .public)]")
		self.selectedEndpointID = endpoint?.id

		if endpoint != nil {
			refreshContainers()
		} else {
			containersTask?.cancel()
			containersTask = Task {
				containers = []
			}
		}
	}

	@Sendable
	public func inspectContainer(_ containerID: Container.ID) async throws -> ContainerDetails {
		logger.info("Getting details for containerID: \"\(containerID, privacy: .public)\"... [\(String.debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpointID) = try getPortainerAndEndpoint()
			let details = try await portainer.inspectContainer(containerID, endpointID: endpointID)
			logger.notice("Got details for containerID: \(containerID, privacy: .public). [\(String.debugInfo(), privacy: .public)]")
			return details
		} catch {
			logger.error("Failed to get container details: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
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
	///   - errorHandler: `SceneState.ErrorHandler` used to notify the user of errors
	/// - Returns: `Task<Void, Error>` of refresh
	func refresh(errorHandler: SceneState.ErrorHandler? = nil, _debugInfo: String = .debugInfo()) -> Task<Void, Error> {
		let task = Task {
			do {
				await setupTask?.value

				let endpointsTask = refreshEndpoints(errorHandler: errorHandler, _debugInfo: _debugInfo)
				try await endpointsTask.value
				if selectedEndpointID != nil {
					let containersTask = refreshContainers(errorHandler: errorHandler, _debugInfo: _debugInfo)
					try await containersTask.value
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
	///   - errorHandler: `SceneState.ErrorHandler` used to notify the user of errors
	/// - Returns: `Task<Void, Error>` of refresh
	func refreshEndpoints(errorHandler: SceneState.ErrorHandler? = nil, _debugInfo: String = .debugInfo()) -> Task<Void, Error> {
		endpointsTask?.cancel()
		let task = Task {
			do {
				self.endpoints = try await getEndpoints()
			} catch {
				if Task.isCancelled { return }
				errorHandler?(error, _debugInfo)
				throw error
			}
			endpointsTask?.cancel()
		}
		endpointsTask = task
		return task
	}

	@discardableResult @MainActor
	/// Refreshes containers, storing the task and handling errors.
	/// Used as user-accessible method of refreshing central data.
	/// - Parameters:
	///   - errorHandler: `SceneState.ErrorHandler` used to notify the user of errors
	/// - Returns: `Task<Void, Error>` of refresh
	func refreshContainers(errorHandler: SceneState.ErrorHandler? = nil, _debugInfo: String = .debugInfo()) -> Task<Void, Error> {
		containersTask?.cancel()
		let task = Task {
			do {
				self.containers = try await getContainers()
			} catch {
				if Task.isCancelled { return }
				errorHandler?(error, _debugInfo)
				throw error
			}
			containersTask?.cancel()
		}
		containersTask = task
		return task
	}

}

// MARK: - PortainerStore+Private

private extension PortainerStore {

	@Sendable
	func getEndpoints() async throws -> [Endpoint] {
		logger.info("Getting endpoints... [\(String.debugInfo(), privacy: .public)]")
		do {
			guard let portainer else {
				throw PortainerError.noPortainer
			}
			let endpoints = try await portainer.fetchEndpoints()
			logger.notice("Got \(endpoints.count, privacy: .public) endpoints. [\(String.debugInfo(), privacy: .public)]")
			return endpoints.sorted()
		} catch {
			logger.error("Failed to get endpoints: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@Sendable
	func getContainers() async throws -> [Container] {
		logger.info("Getting containers... [\(String.debugInfo(), privacy: .public)]")
		do {
			let (portainer, endpointID) = try getPortainerAndEndpoint()
			let containers = try await portainer.fetchContainers(for: endpointID)
			logger.notice("Got \(containers.count, privacy: .public) containers. [\(String.debugInfo(), privacy: .public)]")
			return containers.sorted()
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			throw error
		}
	}

}

// MARK: - PortainerStore+Helpers

private extension PortainerStore {

	/// Unwraps `portainer` and `selectedEndpoint`, or throws an error if there's none.
	/// - Returns: Unwrapped `(Portainer, Endpoint.ID)`
	func getPortainerAndEndpoint() throws -> (Portainer, Endpoint.ID) {
		guard let portainer else {
			throw PortainerError.noPortainer
		}
		guard let selectedEndpointID else {
			throw PortainerError.noSelectedEndpoint
		}
		return (portainer, selectedEndpointID)
	}

}

// MARK: - PortainerStore+OnDidChange

private extension PortainerStore {

	func onSelectedEndpointIDChange(_ selectedEndpointID: Endpoint.ID?) {
		Preferences.shared.selectedEndpointID = selectedEndpointID
	}

	func onEndpointsChange(_ endpoints: [Endpoint]) {
		if endpoints.isEmpty {
			containers = []
			selectedEndpointID = nil
		} else if endpoints.count == 1 {
			selectedEndpointID = endpoints.first?.id
		} else {
			let storedEndpointID = Preferences.shared.selectedEndpointID
			if endpoints.contains(where: { $0.id == storedEndpointID }) {
				selectedEndpointID = storedEndpointID
			}
		}
	}

	func onContainersChange(_ containers: [Container]) {
		storeContainers(containers)
	}

}

// MARK: - PortainerStore+Persistence

private extension PortainerStore {

	@discardableResult
	/// Loads authorization token for saved server and initializes `Portainer` with it.
	func setupIfStored() -> Bool {
		logger.info("Looking for token... [\(String.debugInfo(), privacy: .public)]")
		do {
			guard let selectedServer = Preferences.shared.selectedServer,
				  let selectedServerURL = URL(string: selectedServer) else {
				logger.info("No selectedServer. [\(String.debugInfo(), privacy: .public)]")
				return false
			}

			let token = try keychain.getToken(for: selectedServerURL)
			self.portainer = Portainer(url: selectedServerURL, token: token)

			logger.notice("Got token for URL: \"\(selectedServerURL.absoluteString, privacy: .sensitive)\" :) [\(String.debugInfo(), privacy: .public)]")
			return true
		} catch {
			logger.error("Failed to load token: \(String(describing: error), privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			return false
		}
	}

	/// Stores containers to CoreData store.
	/// - Parameter containers: Containers to store
	func storeContainers(_ containers: [Container]) {
		logger.info("Saving \(containers.count, privacy: .public) containers... [\(String.debugInfo(), privacy: .public)]")

		do {
			let context = PersistenceController.shared.backgroundContext
			containers.forEach { container in
				let storedContainer = StoredContainer(context: context)
				storedContainer.id = container.id
				storedContainer.name = container.displayName
			}

			let saved = try context.saveIfNeeded()
			logger.notice("Inserted \(self.containers.count, privacy: .public) containers, needed to save: \(saved, privacy: .public). [\(String.debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to store containers: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
		}
	}

	/// Fetches stored containers and returns them.
	/// - Returns: Mapped [Container] from CoreData store.
	func loadStoredContainers() -> [Container] {
		logger.info("Loading stored containers... [\(String.debugInfo(), privacy: .public)]")

		do {
			let context = PersistenceController.shared.backgroundContext
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
					return Container(id: $0.id ?? "", names: names)
				}
				.sorted()

			logger.notice("Got \(containers.count, privacy: .public) containers. [\(String.debugInfo(), privacy: .public)]")
			return containers
		} catch {
			logger.error("Failed to fetch stored containers: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			return []
		}
	}

}
