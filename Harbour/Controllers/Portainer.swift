//
//  Portainer.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import Combine
import os.log
import PortainerKit
import Keychain
import WidgetKit

@MainActor
final class Portainer: ObservableObject {
	public typealias ContainerInspection = (general: PortainerKit.Container?, details: PortainerKit.ContainerDetails)

	// MARK: - Public properties

	public static let shared: Portainer = Portainer()

	@Published public internal(set) var servers: [URL]
	@Published public internal(set) var isSetup: Bool = false
	@Published public internal(set) var isLoggedIn: Bool = false

	@Published public internal(set) var fetchingEndpoints: Bool = false
	@Published public internal(set) var fetchingContainers: Bool = false

	@Published public internal(set) var containers: [PortainerKit.Container] = []

#if IOS
	@Published public var attachedContainer: AttachedContainer? = nil
#endif

	@Published public internal(set) var endpoints: [PortainerKit.Endpoint] = [] {
		didSet {
			if selectedEndpointID == nil,
			   let storedEndpointID = Preferences.shared.selectedEndpointID,
			   endpoints.contains(where: { $0.id == storedEndpointID }) {
				selectedEndpointID = storedEndpointID
			}
		}
	}

	@Published public var selectedEndpointID: Int? = Preferences.shared.selectedEndpointID {
		didSet {
			logger.info("Selected endpoint with ID \(self.selectedEndpointID ?? -1, privacy: .sensitive(mask: .hash)) [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			
			Preferences.shared.selectedEndpointID = selectedEndpointID
			
			if let endpointID = selectedEndpointID {
				Task {
					do {
						try await self.getContainers(endpointID: endpointID)
					} catch {
						self.handle(error)
					}
				}
			} else {
				containers = []
			}
		}
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
		
		if let url = Preferences.shared.selectedServer {
			Task {
				do {
					if !self.servers.contains(url) {
						self.servers.append(url)
					}
					
					try await setup(with: url)
				} catch {
					handle(error)
				}
			}
		}
		
		#warning("TODO: Load cached containers from CoreData")
	}

	// MARK: - Public functions
	
	/// Sets up Portainer with supplied server URL
	/// - Parameters:
	///   - url: Server URL
	public func setup(with url: URL) async throws {
		logger.info("Setting up, URL: \(url.absoluteString, privacy: .sensitive(mask: .hash)) [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
				
		if let token = try? keychain.getToken(server: url) {
			api = PortainerKit(url: url, token: token)
		} else if let credentials = try? keychain.getCredentials(server: url) {
			logger.notice("No token stored, but got credentials [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			try await login(url: url, username: credentials.username, password: credentials.password, savePassword: true)
		} else {
			logger.notice("No credentials, logging out [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			throw PortainerError.noCredentials
		}
		
		isSetup = true
		Preferences.shared.selectedServer = url
	}

	/// Logs in to Portainer.
	/// - Parameters:
	///   - url: Endpoint URL
	///   - username: Username
	///   - password: Password
	///   - savePassword: Should password be saved?
	/// - Returns: Result containing JWT token or error.
	public func login(url: URL, username: String, password: String, savePassword: Bool) async throws {
		logger.info("Logging in with credentials, URL: \(url.absoluteString, privacy: .sensitive(mask: .hash))... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		let api = PortainerKit(url: url)
		
		do {
			let token = try await api.login(username: username, password: password)
			
			logger.info("Successfully logged in! [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			self.api = api
			self.isSetup = true
			
			try? keychain.saveToken(server: url, username: username, token: token, comment: Localization.KEYCHAIN_TOKEN_COMMENT.localized, hasPassword: savePassword)
			if savePassword {
				try? keychain.saveCredentials(server: url, username: username, password: password, comment: Localization.KEYCHAIN_CREDS_COMMENT.localized)
			}
			
			DispatchQueue.main.async {
				self.isLoggedIn = true
				Preferences.shared.selectedServer = url
				if !self.servers.contains(url) {
					self.servers.append(url)
				}
			}
		} catch {
			handle(error)
			throw error
		}
	}

	/// Cleans up local data (used after logging out)
	public func cleanup() {
		logger.info("Cleaning up! [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
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
	
	/// Removes credentials for supplied server URL
	/// - Parameter url: URL to remove credentials for
	public func logout(from url: URL) throws {
		logger.info("Logging out from \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\" [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")

		try keychain.removeCredentials(server: url)
		try keychain.removeToken(server: url)
		servers.remove(url)

		if Preferences.shared.selectedServer == url {
			Preferences.shared.selectedServer = nil
		}
		
		if serverURL == url {
			cleanup()
		}
	}

	/// Fetches available endpoints.
	/// - Returns: `[PortainerKit.Endpoint]`
	@discardableResult
	public func getEndpoints() async throws -> [PortainerKit.Endpoint] {
		logger.info("Getting endpoints... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		guard let api = api else { throw PortainerError.noAPI }
		fetchingEndpoints = true
		defer { fetchingEndpoints = false }
		
		do {
			let endpoints = try await api.getEndpoints()
			
			logger.info("Got \(endpoints.count, privacy: .public) endpoint(s). [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			DispatchQueue.main.async {
				self.isLoggedIn = true
				self.endpoints = endpoints
			}
			
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
	public func getContainers(endpointID: Int? = nil, containerID: PortainerKit.Container.ID? = nil) async throws -> [PortainerKit.Container] {
		let endpointID = endpointID ?? self.selectedEndpointID
		logger.info("Getting containers for endpointID: \(endpointID ?? -1, privacy: .public)... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }

		let filters: [String: [String]]?
		if let containerID = containerID {
			filters = ["id": [containerID]]
		} else {
			filters = nil
		}
		
		fetchingContainers = true
		defer { fetchingContainers = false }
		
		do {
			let containers = try await api.getContainers(for: endpointID, filters: filters ?? [:])
			
			#if IOS
			WidgetCenter.shared.reloadTimelines(ofKind: Constants.Widgets.statusWidgetKind)
			#endif
			
			logger.info("Got \(containers.count, privacy: .public) container(s) for endpointID: \(endpointID, privacy: .sensitive(mask: .hash)). [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			DispatchQueue.main.async {
				self.isLoggedIn = true
				self.containers = containers
			}
			
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
	public func inspectContainer(_ container: PortainerKit.Container, endpointID: Int? = nil) async throws -> ContainerInspection {
		let endpointID = endpointID ?? self.selectedEndpointID
		
		logger.info("Inspecting container with ID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID ?? -1, privacy: .sensitive(mask: .hash))... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }
		
		do {
			async let general = api.getContainers(for: endpointID, filters: ["id": [container.id]]).first(where: { $0.id == container.id })
			async let details = api.inspectContainer(container.id, endpointID: endpointID)
			let result: ContainerInspection = (try await general, try await details)
			logger.info("Got details for containerID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash)). [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			
			if let general = result.general,
			   let index = self.containers.firstIndex(of: container) {
				DispatchQueue.main.async {
					self.containers[index] = general
				}
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
	public func execute(_ action: PortainerKit.ExecuteAction, on containerID: PortainerKit.Container.ID, endpointID: Int? = nil) async throws {
		let endpointID = endpointID ?? self.selectedEndpointID
		
		logger.info("Executing action \"\(action.rawValue, privacy: .public)\" for containerID: \(containerID), endpointID: \(endpointID ?? -1, privacy: .sensitive(mask: .hash))... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }
		
		do {
			try await api.execute(action, containerID: containerID, endpointID: endpointID)
			logger.info("Executed action \(action.rawValue, privacy: .public) for containerID: \(containerID), endpointID: \(endpointID, privacy: .sensitive(mask: .hash)). [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
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
	public func getLogs(from containerID: PortainerKit.Container.ID, endpointID: Int? = nil, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false) async throws -> String {
		let endpointID = endpointID ?? self.selectedEndpointID
		
		logger.info("Getting logs from containerID: \(containerID, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID ?? -1, privacy: .sensitive(mask: .hash))... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }

		do {
			let logs = try await api.getLogs(containerID: containerID, endpointID: endpointID, since: since, tail: tail, displayTimestamps: displayTimestamps)
			logger.info("Got logs from containerID: \(containerID, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))! [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
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
		if let attachedContainer = attachedContainer, attachedContainer.container.id == container.id {
			return attachedContainer
		}
		
		let endpointID = endpointID ?? self.selectedEndpointID
		
		logger.info("Attaching to containerID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID ?? -1, privacy: .sensitive(mask: .hash))... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }
		
		do {
			let messagePassthroughSubject = try api.attach(to: container.id, endpointID: endpointID)
			logger.info("Attached to containerID: \(container.id, privacy: .sensitive(mask: .hash)), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))! [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			
			let attachedContainer = AttachedContainer(container: container, messagePassthroughSubject: messagePassthroughSubject)
			attachedContainer.endpointID = endpointID
			attachedContainer.onDisconnect = { [weak self] in
				self?.attachedContainer = nil
			}
			self.attachedContainer = attachedContainer
			
			return attachedContainer
		} catch {
			handle(error)
			throw error
		}
	}
	#endif

	// MARK: - Private functions

	/// Handles potential errors
	/// - Parameter error: Error to handle
	private func handle(_ error: Error, _function: StaticString = #function, _fileID: StaticString = #fileID, _line: Int = #line) {
		logger.error("\(String(describing: error)) (\(_function) [\(_fileID):\(_line)])")
		
		// PortainerKit
		if let error = error as? PortainerKit.APIError {
			switch error {
				case .invalidJWTToken: do {
					guard let url = serverURL ?? Preferences.shared.selectedServer else { return }
					
					try? keychain.removeToken(server: url)
					if let url = serverURL ?? Preferences.shared.selectedServer,
					   let creds = try? keychain.getCredentials(server: url) {
						logger.notice("Received `invalidJWTToken`, but has credentials! Trying to refresh... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
						
						Task {
							do {
								try await login(url: url, username: creds.username, password: creds.password, savePassword: true)
								try await self.getEndpoints()
							} catch {
								if let error = error as? PortainerKit.APIError, error == .invalidCredentials {
									logger.notice("Credentials invalid, logging out :( [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
									try logout(from: url)
								} else {
									throw error
								}
							}
						}
					}
				}
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

private extension Portainer {
	enum KeychainKeys {
		static let token: String = "token"
		static let username: String = "username"
		static let password: String = "password"
	}
}
