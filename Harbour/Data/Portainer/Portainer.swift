//
//  Portainer.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Combine
import KeychainAccess
import os.log
import PortainerKit
import SwiftUI

final class Portainer: ObservableObject {
	// MARK: - Public properties

	public static let shared: Portainer = Portainer()
	
	// MARK: Miscellaneous
	
	@Published public var isLoggedIn: Bool = false
	
	// MARK: Endpoint
	
	@Published public var selectedEndpoint: PortainerKit.Endpoint? = nil {
		didSet {
			if let endpointID = selectedEndpoint?.id {
				Task {
					do {
						try await getContainers(endpointID: endpointID)
					} catch {
						AppState.shared.handle(error)
					}
				}
			} else {
				containers = []
			}
		}
	}

	@Published public private(set) var endpoints: [PortainerKit.Endpoint] = [] {
		didSet {
			if endpoints.count == 1 {
				selectedEndpoint = endpoints.first
			} else if endpoints.isEmpty {
				selectedEndpoint = nil
			}
		}
	}
	
	// MARK: Containers
	
	public let refreshCurrentContainerPassthroughSubject: PassthroughSubject<Void, Never> = .init()
	@Published public var attachedContainer: AttachedContainer? = nil
	@Published public private(set) var containers: [PortainerKit.Container] = []
	
	// MARK: - Private properties
	
	private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Portainer")
	private let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier!, accessGroup: "\(Bundle.main.appIdentifierPrefix)group.\(Bundle.main.bundleIdentifier!)").synchronizable(true).accessibility(.afterFirstUnlock)
	private let ud: UserDefaults = Preferences.shared.ud
	private var api: PortainerKit?
	
	// MARK: - init
	
	private init() {
		// Check if endpointURL is saved
		if let urlString = Preferences.shared.endpointURL, let url = URL(string: urlString) {
			// It is, try to log in
			logger.debug("Has saved URL: \(url, privacy: .sensitive)")
			
			Task {
				// Check if token is saved
				if let token = try? keychain.get(KeychainKeys.token) {
					// Yeah - use it and fetch endpoints
					logger.debug("Also has token, cool! Using it 😊")
					self.api = PortainerKit(url: url, token: token)
					
					do {
						try await self.getEndpoints()
					} catch {
						// Something went wrong! Check if token was invalid and has saved credentials
						if error as? PortainerKit.APIError == PortainerKit.APIError.invalidJWTToken,
						   let username = try? keychain.get(KeychainKeys.username), let password = try? keychain.get(KeychainKeys.password) {
							// Yup - try to use them to refresh the token
							logger.debug("Saved token is invalid, but has credentials!")
							
							do {
								try await login(url: url, username: username, password: password, savePassword: true)
								try await self.getEndpoints()
								// Success!
							} catch {
								// Something went wrong - log out 😞
								logOut()
								AppState.shared.handle(error)
							}
						} else {
							// Error was regarding something else OR there's no saved credentials 😕
							AppState.shared.handle(error)
							logOut()
						}
					}
				} else if let username = try? keychain.get(KeychainKeys.username), let password = try? keychain.get(KeychainKeys.password) {
					// No token BUT has credentials! Try to use them...
					logger.debug("No saved token, but has credentials!")
					
					do {
						try await login(url: url, username: username, password: password, savePassword: true)
						try await self.getEndpoints()
						// Got it!
					} catch {
						// Something went wrong 😑
						logOut()
						AppState.shared.handle(error)
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
		logger.debug("Logging in! URL: \(url.absoluteString, privacy: .sensitive)")
		let api = PortainerKit(url: url)
		self.api = api
		
		let activeActionID = generateActionID(url, username, password)
		AppState.shared.activeNetworkActivities.insert(activeActionID)
		defer { AppState.shared.activeNetworkActivities.remove(activeActionID) }
		
		let token = try await api.login(username: username, password: password)
		
		logger.debug("Successfully logged in!")
		
		DispatchQueue.main.async { [weak self] in
			self?.isLoggedIn = true
			Preferences.shared.endpointURL = url.absoluteString
		}
		try keychain.comment(Localization.KEYCHAIN_TOKEN_COMMENT.localizedString).label("Harbour (token)").set(token, key: KeychainKeys.token)
		
		if savePassword {
			let keychain = self.keychain.comment(Localization.KEYCHAIN_CREDS_COMMENT.localizedString)
			try keychain.label("Harbour (username)").set(username, key: KeychainKeys.username)
			try keychain.label("Harbour (password)").set(password, key: KeychainKeys.password)
		}
	}
	
	/// Logs out, removing all local authentication.
	public func logOut() {
		logger.info("Logging out")
		
		try? keychain.removeAll()
		
		DispatchQueue.main.async {
			self.isLoggedIn = false
			self.selectedEndpoint = nil
			self.endpoints = []
			self.containers = []
			self.attachedContainer = nil
		}
	}
	
	/// Fetches available endpoints.
	/// - Returns: `[PortainerKit.Endpoint]`
	@discardableResult
	public func getEndpoints() async throws -> [PortainerKit.Endpoint] {
		logger.debug("Getting endpoints...")
		
		guard let api = api else { throw PortainerError.noAPI }
		
		let activeActionID = generateActionID()
		AppState.shared.activeNetworkActivities.insert(activeActionID)
		defer { AppState.shared.activeNetworkActivities.remove(activeActionID) }
		
		do {
			let endpoints = try await api.getEndpoints()
			
			logger.debug("Got \(endpoints.count) endpoint(s).")
			DispatchQueue.main.async { [weak self] in
				self?.endpoints = endpoints
				self?.isLoggedIn = true
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
	public func getContainers(endpointID: Int) async throws -> [PortainerKit.Container] {
		logger.debug("Getting containers for endpointID: \(endpointID)...")
		
		guard let api = api else { throw PortainerError.noAPI }

		let activeActionID = generateActionID(endpointID)
		AppState.shared.activeNetworkActivities.insert(activeActionID)
		defer { AppState.shared.activeNetworkActivities.remove(activeActionID) }

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
	/// - Returns: `PortainerKit.ContainerDetails`
	public func inspectContainer(_ container: PortainerKit.Container) async throws -> PortainerKit.ContainerDetails {
		logger.debug("Inspecting container with ID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = selectedEndpoint?.id else { throw PortainerError.noEndpoint }

		let activeActionID = generateActionID(container.id)
		AppState.shared.activeNetworkActivities.insert(activeActionID)
		defer { AppState.shared.activeNetworkActivities.remove(activeActionID) }
		
		do {
			let containerDetails = try await api.inspectContainer(container.id, endpointID: endpointID)
			logger.debug("Got details for containerID: \(container.id), endpointID: \(endpointID).")
			return containerDetails
		} catch {
			handle(error)
			throw error
		}
	}
	
	/// Executes an action on selected container.
	/// - Parameters:
	///   - action: Action to be executed
	///   - container: Container, where the action will be executed
	public func execute(_ action: PortainerKit.ExecuteAction, on container: PortainerKit.Container) async throws {
		logger.debug("Executing action \(action.rawValue) for containerID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = selectedEndpoint?.id else { throw PortainerError.noEndpoint }
		
		let activeActionID = generateActionID(action, container.id)
		AppState.shared.activeNetworkActivities.insert(activeActionID)
		defer { AppState.shared.activeNetworkActivities.remove(activeActionID) }
		
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
	public func getLogs(from container: PortainerKit.Container, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false) async throws -> String {
		logger.debug("Getting logs from containerID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = selectedEndpoint?.id else { throw PortainerError.noEndpoint }
		
		let activeActionID = generateActionID(container.id)
		AppState.shared.activeNetworkActivities.insert(activeActionID)
		defer { AppState.shared.activeNetworkActivities.remove(activeActionID) }

		do {
			let logs = try await api.getLogs(containerID: container.id, endpointID: endpointID, since: since, tail: tail, displayTimestamps: displayTimestamps)
			logger.debug("Got logs from containerID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)!")
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
	public func attach(to container: PortainerKit.Container) throws -> AttachedContainer {
		if let attachedContainer = attachedContainer, attachedContainer.container.id == container.id {
			return attachedContainer
		}
		
		logger.debug("Attaching to containerID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = selectedEndpoint?.id else { throw PortainerError.noEndpoint }
		
		let activeActionID = generateActionID(container.id)
		AppState.shared.activeNetworkActivities.insert(activeActionID)
		defer { AppState.shared.activeNetworkActivities.remove(activeActionID) }
		
		do {
			let messagePassthroughSubject = try api.attach(to: container.id, endpointID: endpointID)
			logger.debug("Attached to containerID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)!")
			
			let attachedContainer = AttachedContainer(container: container, messagePassthroughSubject: messagePassthroughSubject)
			self.attachedContainer = attachedContainer
			
			return attachedContainer
		} catch {
			handle(error)
			throw error
		}
	}
	
	// MARK: - Private functions
	
	private func generateActionID(_ args: Any..., _function: StaticString = #function) -> String {
		"Portainer.\(_function)(\(String(describing: args)))"
	}
	
	private func handle(_ error: Error) {
		guard let error = error as? PortainerKit.APIError else { return }
		
		switch error {
			case .invalidJWTToken:
				logOut()
			default:
				break
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
