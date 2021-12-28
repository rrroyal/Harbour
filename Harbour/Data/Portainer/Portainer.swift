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
import KeychainAccess

final class Portainer: ObservableObject {
	public typealias ContainerInspection = (general: PortainerKit.Container?, details: PortainerKit.ContainerDetails)
	
	// MARK: - Public properties

	public static let shared: Portainer = Portainer()
	
	@Published public private(set) var isLoggedIn: Bool = false
			
	// MARK: Endpoint
	
	@Published public var selectedEndpointID: Int? = nil {
		didSet {
			Preferences.shared.selectedEndpointID = selectedEndpointID
			
			if let endpointID = selectedEndpointID {
				Task {
					do {
						try await getContainers(endpointID: endpointID)
					} catch {
						handle(error)
					}
				}
			} else {
				containers = []
			}
		}
	}

	@Published public private(set) var endpoints: [PortainerKit.Endpoint] = [] {
		didSet {
			if endpoints.contains(where: { $0.id == selectedEndpointID }) {
				return
			}
			
			if let storedEndpointID = Preferences.shared.selectedEndpointID, let storedEndpoint = endpoints.first(where: { $0.id == storedEndpointID }) {
				selectedEndpointID = storedEndpoint.id
			} else if endpoints.count == 1 {
				selectedEndpointID = endpoints.first?.id
			} else if endpoints.isEmpty {
				selectedEndpointID = nil
			}
		}
	}
	
	// MARK: Containers
	
	public let refreshContainerPassthroughSubject: PassthroughSubject<String, Never> = .init()
	@Published public var attachedContainer: AttachedContainer? = nil
	@Published public private(set) var containers: [PortainerKit.Container] = []
	
	// MARK: - Private variables
	
	private var activeActions: Set<String> = []
	
	// MARK: - Private util
	
	private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Portainer")
	private let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier!, accessGroup: "\(Bundle.main.appIdentifierPrefix)group.\(Bundle.main.bundleIdentifier!)").synchronizable(true).accessibility(.afterFirstUnlock)
	private let ud: UserDefaults = Preferences.ud
	private var api: PortainerKit?
	
	// MARK: - init
	
	private init() {
		if let urlString = Preferences.shared.endpointURL, let url = URL(string: urlString) {
			logger.debug("Has saved URL: \(url, privacy: .sensitive)")
			
			if let token = try? keychain.get(KeychainKeys.token) {
				logger.debug("Has token, cool! Using it 😊")
				api = PortainerKit(url: url, token: token)
				isLoggedIn = true
				DispatchQueue.main.async {
					Task {
						AppState.shared.fetchingMainScreenData = true
						try await self.getEndpoints()
						AppState.shared.fetchingMainScreenData = false
					}
				}
			}
		}
	}
	
	// MARK: - Public functions
	
	/// Logs in to Portainer.
	/// - Parameters:
	///   - url: Endpoint URL
	///   - username: Username
	///   - password: Password
	///   - savePassword: Should password be saved?
	/// - Returns: Result containing JWT token or error.
	public func login(url: URL, username: String, password: String, savePassword: Bool) async throws {
		logger.debug("Logging in, URL: \(url.absoluteString, privacy: .sensitive)...")
		let api = PortainerKit(url: url)
		self.api = api
		
		do {
			let token = try await api.login(username: username, password: password)
			
			logger.debug("Successfully logged in!")
			
			DispatchQueue.main.async {
				self.isLoggedIn = true
				Preferences.shared.endpointURL = url.absoluteString
				Preferences.shared.hasSavedCredentials = true
			}
			
			try keychain.comment(Localization.KEYCHAIN_TOKEN_COMMENT.localized).label("Harbour (token)").set(token, key: KeychainKeys.token)
			if savePassword {
				let keychain = self.keychain.comment(Localization.KEYCHAIN_CREDS_COMMENT.localized)
				try keychain.label("Harbour (username)").set(username, key: KeychainKeys.username)
				try keychain.label("Harbour (password)").set(password, key: KeychainKeys.password)
			}
		} catch {
			handle(error)
			throw error
		}
	}
	
	/// Logs out, removing all local authentication.
	public func logOut(removeEndpointURL: Bool = false) {
		logger.info("Logging out")
		
		try? keychain.removeAll()
		
		api = nil
		
		DispatchQueue.main.async {
			self.isLoggedIn = false
			self.selectedEndpointID = nil
			self.endpoints = []
			self.containers = []
			self.attachedContainer = nil
			Preferences.shared.hasSavedCredentials = false
			AppState.shared.fetchingMainScreenData = false
			
			if removeEndpointURL {
				Preferences.shared.endpointURL = nil
			}
		}
	}
	
	/// Fetches available endpoints.
	/// - Returns: `[PortainerKit.Endpoint]`
	@discardableResult
	public func getEndpoints() async throws -> [PortainerKit.Endpoint] {
		logger.debug("Getting endpoints...")
		
		guard let api = api else { throw PortainerError.noAPI }
		
		do {
			let endpoints = try await api.getEndpoints()
			
			logger.debug("Got \(endpoints.count) endpoint(s).")
			DispatchQueue.main.async { [weak self] in
				self?.endpoints = endpoints
			}
			
			return endpoints
		} catch {
			handle(error)
			throw error
		}
	}
	
	/// Fetches available containers for selected endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: `[PortainerKit.Container]`
	@discardableResult
	public func getContainers(endpointID: Int? = nil) async throws -> [PortainerKit.Container] {
		let endpointID = endpointID ?? self.selectedEndpointID
		logger.debug("Getting containers for endpointID: \(endpointID ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }

		do {
			let containers = try await api.getContainers(for: endpointID)
			
			logger.debug("Got \(containers.count) container(s) for endpointID: \(endpointID).")
			DispatchQueue.main.async { [weak self] in
				self?.containers = containers
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
		
		logger.debug("Inspecting container with ID: \(container.id), endpointID: \(endpointID ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }
		
		do {
			async let general = api.getContainers(for: endpointID, filters: ["id": [container.id]]).first(where: { $0.id == container.id })
			async let details = api.inspectContainer(container.id, endpointID: endpointID)
			let result: ContainerInspection = (try await general, try await details)
			logger.debug("Got details for containerID: \(container.id), endpointID: \(endpointID).")
			
			if let general = result.general {
				DispatchQueue.main.async { [weak self] in
					if let index = self?.containers.firstIndex(of: container) {
						self?.containers[index] = general
					}
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
	public func execute(_ action: PortainerKit.ExecuteAction, on container: PortainerKit.Container, endpointID: Int? = nil) async throws {
		let endpointID = endpointID ?? self.selectedEndpointID
		
		logger.debug("Executing action \"\(action.rawValue)\" for containerID: \(container.id), endpointID: \(endpointID ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }
		
		do {
			try await api.execute(action, containerID: container.id, endpointID: endpointID)
			logger.debug("Executed action \(action.rawValue) for containerID: \(container.id), endpointID: \(endpointID).")
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
	public func getLogs(from container: PortainerKit.Container, endpointID: Int? = nil, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false) async throws -> String {
		let endpointID = endpointID ?? self.selectedEndpointID
		
		logger.debug("Getting logs from containerID: \(container.id), endpointID: \(endpointID ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }

		do {
			let logs = try await api.getLogs(containerID: container.id, endpointID: endpointID, since: since, tail: tail, displayTimestamps: displayTimestamps)
			logger.debug("Got logs from containerID: \(container.id), endpointID: \(endpointID)!")
			return logs
		} catch {
			handle(error)
			throw error
		}
	}
	
	/// Attaches to container through a WebSocket connection.
	/// - Parameter container: Container to attach to
	/// - Returns: Result containing `AttachedContainer` or error.
	@discardableResult
	public func attach(to container: PortainerKit.Container, endpointID: Int? = nil) throws -> AttachedContainer {
		if let attachedContainer = attachedContainer, attachedContainer.container.id == container.id {
			return attachedContainer
		}
		
		let endpointID = endpointID ?? self.selectedEndpointID
		
		logger.debug("Attaching to containerID: \(container.id), endpointID: \(endpointID ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }
		
		do {
			let messagePassthroughSubject = try api.attach(to: container.id, endpointID: endpointID)
			logger.debug("Attached to containerID: \(container.id), endpointID: \(endpointID)!")
			
			let attachedContainer = AttachedContainer(container: container, messagePassthroughSubject: messagePassthroughSubject)
			self.attachedContainer = attachedContainer
			
			return attachedContainer
		} catch {
			handle(error)
			throw error
		}
	}
	
	// MARK: - Private functions
	
	/// Handles potential errors
	/// - Parameter error: Error to handle
	private func handle(_ error: Error, _function: StaticString = #function, _fileID: StaticString = #fileID, _line: Int = #line) {
		logger.error("\(String(describing: error)) (\(_function) [\(_fileID):\(_line)])")
		
		// PortainerKit
		if let error = error as? PortainerKit.APIError {
			switch error {
				case .invalidJWTToken: do {
					try? keychain.remove(KeychainKeys.token)
					
					if let urlString = api?.url.absoluteString ?? Preferences.shared.endpointURL,
					   let url = URL(string: urlString),
					   let username = try? keychain.get(KeychainKeys.username),
					   let password = try? keychain.get(KeychainKeys.password) {
						logger.debug("Received `invalidJWTToken`, but has credentials! Trying to refresh...")
						
						Task {
							do {
								try await login(url: url, username: username, password: password, savePassword: true)
								try await self.getEndpoints()
							} catch {
								if let error = error as? PortainerKit.APIError, error == .invalidCredentials {
									logger.debug("Credentials invalid, logging out :(")
									logOut()
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
