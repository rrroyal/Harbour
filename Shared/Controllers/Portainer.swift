//
//  Portainer.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import Combine
import os.log
import CoreData
import WidgetKit
import Keychain
import PortainerKit

@MainActor
final class Portainer: ObservableObject {
	public typealias ContainerInspection = (general: PortainerKit.Container?, details: PortainerKit.ContainerDetails)

	// MARK: - Public properties

	public static let shared: Portainer = Portainer()

	@Published @MainActor public internal(set) var servers: [URL]
	@Published @MainActor public internal(set) var isSetup: Bool = false
	@Published @MainActor public internal(set) var isLoggedIn: Bool = false

	@Published @MainActor public internal(set) var isSettingUp: Bool = false
	@Published @MainActor public internal(set) var isFetchingEndpoints: Bool = false
	@Published @MainActor public internal(set) var isFetchingContainers: Bool = false

	@Published @MainActor public internal(set) var containers: [PortainerKit.Container] = []

#if IOS
	@Published @MainActor public var attachedContainer: AttachedContainer? = nil
#endif

	@Published @MainActor public internal(set) var endpoints: [PortainerKit.Endpoint] = [] {
		didSet {
			if selectedEndpointID == nil {
				if let storedEndpointID = Preferences.shared.selectedEndpointID, endpoints.contains(where: { $0.id == storedEndpointID }) {
					selectedEndpointID = storedEndpointID
				} else if endpoints.count == 1 {
					selectedEndpointID = endpoints.first?.id
				}
			}
		}
	}

	@Published @MainActor public private(set) var selectedEndpointID: Int? = Preferences.shared.selectedEndpointID {
		didSet { Preferences.shared.selectedEndpointID = selectedEndpointID }
	}

	public var serverURL: URL? {
		get { api?.url }
	}

	public var hasSavedCredentials: Bool {
		get { !((try? keychain.getURLs()) ?? []).isEmpty }
	}

	public let refreshContainerPassthroughSubject: PassthroughSubject<String, Never> = .init()

	// MARK: - Private variables

	private let keychain: Keychain = Keychain(service: Bundle.main.mainBundleIdentifier, accessGroup: "\(Bundle.main.appIdentifierPrefix!)group.\(Bundle.main.mainBundleIdentifier)")
	private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Portainer")
	private var api: PortainerKit?

	// MARK: - init

	private init() {
		self.servers = (try? keychain.getURLs()) ?? []

		#if IOS
		// try? loadStoredContainers()
		#endif
	}

	// MARK: - Public functions
	
	/// Sets up Portainer with supplied server URL.
	/// - Parameters:
	///   - url: Server URL
	///   - token: Access token
	@Sendable @MainActor public func setup(url: URL? = Preferences.shared.selectedServer, token: String? = nil) async throws {
		do {
			guard let url = url else { throw PortainerError.noServerURL }
			guard url != serverURL else { return }
			guard let token = try? (token ?? keychain.getToken(server: url)) else { throw PortainerError.noToken }

			logger.info("Setting up, URL: \(url.absoluteString, privacy: .sensitive(mask: .hash))...")

			isSettingUp = true
			defer { isSettingUp = false }

			let api = PortainerKit(url: url, token: token)

			try keychain.saveToken(server: url, token: token, comment: Localization.Keychain.tokenComment(Bundle.main.mainBundleIdentifier))
			self.api = api

			isSetup = true
			Preferences.shared.selectedServer = url
		} catch {
			handle(error)
			throw error
		}
	}

	/// Removes credentials for supplied server URL
	/// - Parameter url: URL to remove credentials for
	@Sendable @MainActor public func logout(from url: URL) throws {
		logger.info("Logging out from \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\" ")

		try keychain.removeToken(server: url)
		servers.remove(url)

		if Preferences.shared.selectedServer == url {
			Preferences.shared.selectedServer = nil
		}

		if serverURL == url {
			cleanup()
		}
	}

	/// Cleans up local data (used after logging out)
	@Sendable @MainActor public func cleanup() {
		logger.info("Cleaning up!")
		
		api = nil
		
		DispatchQueue.main.async {
			self.isSetup = false
			self.isLoggedIn = false
			self.selectedEndpointID = nil
			self.endpoints = []
			self.containers = []
			#if IOS
			self.attachedContainer = nil
			#endif
		}
	}

	/// Sets selectedEndpointID and fetches containers
	/// - Parameter endpointID: Endpoint ID
	@Sendable @MainActor public func setSelectedEndpoint(_ endpointID: PortainerKit.Endpoint.ID?) async throws {
		logger.info("Selected endpoint with ID \(endpointID?.description ?? "<none>")")
		selectedEndpointID = endpointID

		do {
			guard let endpointID = endpointID else {
				containers = []
				return
			}

			try await getContainers(endpointID: endpointID)
		} catch {
			handle(error)
			throw error
		}
	}

	/// Fetches available endpoints.
	/// - Returns: `[PortainerKit.Endpoint]`
	@discardableResult
	@Sendable @MainActor public func getEndpoints() async throws -> [PortainerKit.Endpoint] {
		do {
			guard let api = api else { throw PortainerError.noAPI }

			logger.info("Getting endpoints...")

			isFetchingEndpoints = true
			defer { isFetchingEndpoints = false }

			let endpoints = try await api.fetchEndpoints()

			logger.info("Got \(endpoints.count, privacy: .public) endpoint(s). ")
			isLoggedIn = true
			self.endpoints = endpoints

			return endpoints
		} catch {
			handle(error)
			throw error
		}
	}

	/// Fetches available containers for selected endpoint ID.
	/// - Parameters:
	///   - endpointID: Endpoint ID to search
	///   - containerID: Search for container with this ID
	/// - Returns: `[PortainerKit.Container]`
	@discardableResult
	@Sendable @MainActor public func getContainers(endpointID: Int? = nil, containerID: PortainerKit.Container.ID? = nil) async throws -> [PortainerKit.Container] {
		do {
			guard let api = api else { throw PortainerError.noAPI }
			guard let endpointID = endpointID ?? self.selectedEndpointID else { throw PortainerError.noEndpoint }
			logger.info("Getting containers for endpointID: \(endpointID, privacy: .public)...")

			let filters: [String: [String]]?
			if let containerID = containerID {
				filters = ["id": [containerID]]
			} else {
				filters = nil
			}

			isFetchingContainers = true
			defer { isFetchingContainers = false }

			let containers = try await api.fetchContainers(for: endpointID, filters: filters ?? [:])

			#if IOS
			WidgetCenter.shared.reloadTimelines(ofKind: Constants.Widgets.statusWidgetKind)
			#endif

			logger.info("Got \(containers.count, privacy: .public) container(s) for endpointID: \(endpointID, privacy: .sensitive(mask: .hash)).")
			isLoggedIn = true
			self.containers = containers

			#if IOS
//			Task { try? storeContainers(containers: containers) }
			#endif

			return containers
		} catch {
			handle(error)
			throw error
		}
	}

	/// Fetches container details.
	/// - Parameter container: Container to be inspected
	/// - Parameter endpointID: Endpoint ID to inspect
	/// - Returns: `ContainerInspection`
	@Sendable @MainActor public func inspectContainer(_ container: PortainerKit.Container, endpointID: Int? = nil) async throws -> ContainerInspection {
		do {
			guard let api = api else { throw PortainerError.noAPI }
			guard let endpointID = endpointID ?? self.selectedEndpointID else { throw PortainerError.noEndpoint }

			logger.info("Inspecting container with ID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))...")

			async let general = api.fetchContainers(for: endpointID, filters: ["id": [container.id]]).first(where: { $0.id == container.id })
			async let details = api.inspectContainer(container.id, endpointID: endpointID)
			let result = (general: try await general, details: try await details)

			logger.info("Got details for containerID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash)).")

			if let general = result.general,
			   let index = self.containers.firstIndex(of: container) {
				containers[index] = general
			}

			return result
		} catch {
			handle(error)
			throw error
		}
	}

	/// Executes an action on selected container.
	/// - Parameters:
	///   - action: Action to be executed
	///   - container: Container, where the action will be executed
	@Sendable public func execute(_ action: PortainerKit.ExecuteAction, on containerID: PortainerKit.Container.ID, endpointID: Int? = nil) async throws {
		do {
			guard let api = api else { throw PortainerError.noAPI }
			guard let endpointID = endpointID ?? self.selectedEndpointID else { throw PortainerError.noEndpoint }

			logger.info("Executing action \"\(action.rawValue, privacy: .public)\" for containerID: \(containerID), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))...")

			try await api.execute(action, containerID: containerID, endpointID: endpointID)
			logger.info("Executed action \(action.rawValue, privacy: .public) for containerID: \(containerID), endpointID: \(endpointID, privacy: .sensitive(mask: .hash)).")
		} catch {
			handle(error)
			throw error
		}
	}

	/// Fetches logs from selected container.
	/// - Parameters:
	///   - container: Get logs from this container
	///   - since: Logs since this time
	///   - tail: Number of lines
	///   - displayTimestamps: Display timestamps?
	/// - Returns: `String` logs
	@Sendable public func getLogs(from containerID: PortainerKit.Container.ID, endpointID: Int? = nil, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false) async throws -> String {
		do {
			guard let api = api else { throw PortainerError.noAPI }
			guard let endpointID = endpointID ?? self.selectedEndpointID else { throw PortainerError.noEndpoint }

			logger.info("Getting logs from containerID: \(containerID, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))...")

			let logs = try await api.fetchLogs(containerID: containerID, endpointID: endpointID, since: since, tail: tail, displayTimestamps: displayTimestamps)
			logger.info("Got logs from containerID: \(containerID, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))!")
			return logs
		} catch {
			handle(error)
			throw error
		}
	}

	#if IOS
	/// Attaches to container through a WebSocket connection.
	/// - Parameter container: Container to attach to
	/// - Returns: Result containing `AttachedContainer` or error.
	@discardableResult
	public func attach(to container: PortainerKit.Container, endpointID: Int? = nil) throws -> AttachedContainer {
		do {
			if let attachedContainer = attachedContainer, attachedContainer.container.id == container.id {
				return attachedContainer
			}

			guard let api = api else { throw PortainerError.noAPI }
			guard let endpointID = endpointID ?? self.selectedEndpointID else { throw PortainerError.noEndpoint }

			logger.info("Attaching to containerID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))...")

			let messagePassthroughSubject = try api.attach(to: container.id, endpointID: endpointID)
			logger.info("Attached to containerID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))!")

			let attachedContainer = AttachedContainer(container: container, messagePassthroughSubject: messagePassthroughSubject)
			attachedContainer.endpointID = endpointID
			self.attachedContainer = attachedContainer

			return attachedContainer
		} catch {
			handle(error)
			throw error
		}
	}
	#endif

	// MARK: - Private functions

	#if IOS
	/// Stores containers to CoreData as `PKStoredContainer`
	/// - Parameter containers: Containers to store
	private func storeContainers(containers: [PortainerKit.Container]) throws {
		logger.info("(Persistence) Saving containers...")

		let context = Persistence.shared.backgroundContext

		do {
			try context.performAndWait {
				let deleteRequest = NSBatchDeleteRequest(fetchRequest: PKStoredContainer.fetchRequest())
				_ = try? context.execute(deleteRequest)

				let entities = containers.map { $0.toCoreData(context: context) }
				try context.save()
				self.logger.info("(Persistence) Saved \(entities.count) containers!")
			}
		} catch {
			handle(error)
			throw error
		}
	}

	/// Loads stored containers
	@MainActor private func loadStoredContainers() throws {
		logger.info("(Persistence) Fetching stored containers...")

		let context = Persistence.shared.backgroundContext

		do {
			try context.performAndWait {
				let request = PKStoredContainer.fetchRequest()
				let entites = try context.fetch(request)
				let containers = entites.compactMap(PortainerKit.Container.init)
				self.logger.info("(Persistence) Loaded \(containers.count) stored containers!")
				if (self.containers.isEmpty) {
					DispatchQueue.main.async {
						self.containers = containers
					}
				}
			}
		} catch {
			handle(error)
			throw error
		}
	}
	#endif

	/// Handles potential errors
	/// - Parameter error: Error to handle
	private func handle(_ error: Error, _function: StaticString = #function, _fileID: StaticString = #fileID, _line: Int = #line) {
		logger.error("\(String(describing: error)) (\(_function) [\(_fileID):\(_line)])")

		// PortainerKit
		if let error = error as? PortainerKit.APIError {
			switch error {
				case .invalidToken:
					cleanup()
				default:
					break
			}
		} else if let error = error as? URLError {
			switch error.code {
				case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed, .networkConnectionLost, .notConnectedToInternet, .timedOut:
					endpoints = []
					containers = []
					isLoggedIn = false
					#if IOS
					attachedContainer = nil
					#endif
				default:
					break
			}
		}
	}
}
