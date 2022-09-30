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
@MainActor
final class PortainerStore: ObservableObject {
	static let shared: PortainerStore = PortainerStore()

	// MARK: Private properties

	// swiftlint:disable:next force_unwrapping
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PortainerStore")
	internal let keychain: Keychain = Keychain(accessGroup: Bundle.main.groupIdentifier)

	internal var portainer: Portainer?

	internal var setupTask: Task<Void, Never>?
	internal var endpointsTask: Task<Void, Error>?
	internal var containersTask: Task<Void, Error>?

	// MARK: Public properties

	/// Server URL
	public var serverURL: URL? {
		portainer?.url
	}

	@Published private(set) var isSetup: Bool = false

	@Published private(set) var selectedEndpoint: Endpoint? {
		didSet { onSelectedEndpointChange(selectedEndpoint) }
	}

	@Published private(set) var endpoints: [Endpoint] = [] {
		didSet { onEndpointsChange(endpoints) }
	}
	@Published private(set) var containers: [Container] = [] {
		didSet { onContainersChange(containers) }
	}

	// MARK: init

	private init() {
		logger.info("Initialized, loading stored containers... [\(String.debugInfo(), privacy: .public)]")
		setupTask = Task {
			containers = loadStoredContainers()
			loadTokenIfStored()
			setupTask?.cancel()
		}
	}

	// MARK: Public Functions

	@Sendable @MainActor
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
		self.selectedEndpoint = endpoint

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
	public func getEndpoints() async throws {
		logger.info("Getting endpoints... [\(String.debugInfo(), privacy: .public)]")
		do {
			let portainer = try getPortainer()
			let endpoints = try await portainer.fetchEndpoints()
			self.endpoints = endpoints.sorted()
			logger.notice("Got \(endpoints.count, privacy: .public) endpoints. [\(String.debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to get endpoints: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			throw error
		}
	}

	@Sendable
	public func getContainers() async throws {
		logger.info("Getting containers... [\(String.debugInfo(), privacy: .public)]")
		do {
			guard let selectedEndpointID = selectedEndpoint?.id else {
				throw PortainerError.noSelectedEndpoint
			}

			let portainer = try getPortainer()
			let containers = try await portainer.fetchContainers(for: selectedEndpointID)
			self.containers = containers.sorted()
			logger.notice("Got \(containers.count, privacy: .public) containers. [\(String.debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
			throw error
		}
	}

	// MARK: Private Functions

	/// Returns `Portainer`, or throws an error if there's none.
	private func getPortainer() throws -> Portainer {
		guard let portainer else {
			throw PortainerError.noPortainer
		}
		return portainer
	}
}

// MARK: - PortainerStore+Refresh

extension PortainerStore {
	@discardableResult
	func refresh(errorHandler: SceneState.ErrorHandler? = nil, _debugInfo: String = .debugInfo()) -> Task<Void, Error> {
		let task = Task {
			do {
				let endpointsTask = refreshEndpoints(errorHandler: errorHandler, _debugInfo: _debugInfo)
				try await endpointsTask.value
				if selectedEndpoint != nil {
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

	@discardableResult
	func refreshEndpoints(errorHandler: SceneState.ErrorHandler? = nil, _debugInfo: String = .debugInfo()) -> Task<Void, Error> {
		endpointsTask?.cancel()
		let task = Task {
			do {
				try await getEndpoints()
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

	@discardableResult
	func refreshContainers(errorHandler: SceneState.ErrorHandler? = nil, _debugInfo: String = .debugInfo()) -> Task<Void, Error> {
		containersTask?.cancel()
		let task = Task {
			do {
				try await getContainers()
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

// MARK: - PortainerStore+Actions

private extension PortainerStore {
	func onSelectedEndpointChange(_ selectedEndpoint: Endpoint?) {
		Preferences.shared.selectedEndpointID = selectedEndpoint?.id
	}

	func onEndpointsChange(_ endpoints: [Endpoint]) {
		if endpoints.isEmpty {
			containers = []
			selectedEndpoint = nil
		} else if endpoints.count == 1 {
			selectedEndpoint = endpoints.first
		} else {
			let storedEndpointID = Preferences.shared.selectedEndpointID
			let storedEndpoint = endpoints.first(where: { $0.id == storedEndpointID })
			selectedEndpoint = storedEndpoint
		}
	}

	func onContainersChange(_ containers: [Container]) {
		storeContainers(containers)
	}
}

// MARK: - PortainerStore+Persistence

private extension PortainerStore {
	@discardableResult
	func loadTokenIfStored() -> Bool {
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
