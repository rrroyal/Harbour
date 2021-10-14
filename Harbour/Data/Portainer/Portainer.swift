//
//  Portainer.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import Combine
import KeychainAccess
import os.log
import PortainerKit

final class Portainer: ObservableObject {
	// MARK: - Public properties

	public static let shared: Portainer = Portainer()
	
	// MARK: Miscellaneous
	
	@Published public var isLoggedIn: Bool = false
	
	// MARK: Endpoint
	
	@Published public var selectedEndpoint: PortainerKit.Endpoint? = nil {
		didSet {
			Preferences.shared.selectedEndpointID = selectedEndpoint?.id
			
			if let endpointID = selectedEndpoint?.id {
				getContainers(endpointID: endpointID)
			} else {
				containers = []
			}
		}
	}

	@Published public private(set) var endpoints: [PortainerKit.Endpoint] = [] {
		didSet {
			if endpoints.contains(where: { $0.id == selectedEndpoint?.id }) {
				return
			}
			
			if let storedEndpointID = Preferences.shared.selectedEndpointID, let storedEndpoint = endpoints.first(where: { $0.id == storedEndpointID }) {
				selectedEndpoint = storedEndpoint
			} else if endpoints.count == 1 {
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
	
	// MARK: - Private variables
	
	private var activeActions: Set<String> = []
	
	// MARK: - Private util
	
	private let logger: PseudoLogger = PseudoLogger(subsystem: Bundle.main.bundleIdentifier!, category: "Portainer")
	private let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier!).synchronizable(true).accessibility(.afterFirstUnlock)
	private let ud: UserDefaults = Preferences.shared.ud
	private var api: PortainerKit?
	
	// MARK: - init
	
	private init() {
		if let urlString = Preferences.shared.endpointURL, let url = URL(string: urlString) {
			logger.debug("Has saved URL: \(url)")
			
			if let token = try? keychain.get(KeychainKeys.token) {
				logger.debug("Has token, cool! Using it 😊")
				api = PortainerKit(url: url, token: token)
				getEndpoints(completionHandler: { _ in })
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
	public func login(url: URL, username: String, password: String, savePassword: Bool, completionHandler: @escaping (Result<Void, Error>) -> ()) {
		logger.debug("Logging in! URL: \(url.absoluteString)")
		let api = PortainerKit(url: url)
		self.api = api
		
		api.login(username: username, password: password) { result in			
			switch result {
				case .success(let token):
					self.logger.debug("Successfully logged in!")
					
					DispatchQueue.main.async {
						self.isLoggedIn = true
						Preferences.shared.endpointURL = url.absoluteString
					}
					
					try? self.keychain.comment(Localization.KEYCHAIN_TOKEN_COMMENT.localizedString).label("Harbour (token)").set(token, key: KeychainKeys.token)
					if savePassword {
						let keychain = self.keychain.comment(Localization.KEYCHAIN_CREDS_COMMENT.localizedString)
						try? keychain.label("Harbour (username)").set(username, key: KeychainKeys.username)
						try? keychain.label("Harbour (password)").set(password, key: KeychainKeys.password)
					}
					
					completionHandler(.success(()))
				case .failure(let error):
					self.handle(error)
					completionHandler(.failure(error))
			}
		}
	}
	
	/// Logs out, removing all local authentication.
	public func logOut() {
		logger.info("Logging out")
		
		try? keychain.removeAll()
		
		self.api = nil
		
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
	public func getEndpoints(completionHandler: @escaping (Result<[PortainerKit.Endpoint], Error>) -> ()) {
		logger.debug("Getting endpoints...")
		
		guard let api = api else {
			handle(PortainerError.noAPI)
			return
		}
		
		api.getEndpoints() { result in
			completionHandler(result)
			
			switch result {
				case .success(let endpoints):
					self.logger.debug("Got \(endpoints.count) endpoint(s).")
					DispatchQueue.main.async { [weak self] in
						self?.endpoints = endpoints
						self?.isLoggedIn = true
					}
				case .failure(let error):
					self.handle(error)
			}
		}
	}
	
	/// Fetches available containers for selected endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: `[PortainerKit.Container]`
	public func getContainers(endpointID: Int) {
		logger.debug("Getting containers for endpointID: \(endpointID)...")
		
		guard let api = api else {
			handle(PortainerError.noAPI)
			return
		}

		api.getContainers(for: endpointID) { result in
			switch result {
				case .success(let containers):
					self.logger.debug("Got \(containers.count) container(s) for endpointID: \(endpointID).")
					DispatchQueue.main.async { [weak self] in
						self?.containers = containers
					}
				case .failure(let error):
					self.handle(error)
			}
		}
	}
	
	/// Fetches container details.
	/// - Parameter container: Container to be inspected
	/// - Returns: `PortainerKit.ContainerDetails`
	public func inspectContainer(_ container: PortainerKit.Container, completionHandler: @escaping (Result<PortainerKit.ContainerDetails, Error>) -> ()) {
		logger.debug("Inspecting container with ID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else {
			completionHandler(.failure(PortainerError.noAPI))
			handle(PortainerError.noAPI)
			return
		}
		guard let endpointID = selectedEndpoint?.id else {
			completionHandler(.failure(PortainerError.noEndpoint))
			handle(PortainerError.noEndpoint)
			return
		}
		
		api.inspectContainer(container.id, endpointID: endpointID, completionHandler: completionHandler)
		logger.debug("Got details for containerID: \(container.id), endpointID: \(endpointID).")
	}
	
	/// Executes an action on selected container.
	/// - Parameters:
	///   - action: Action to be executed
	///   - container: Container, where the action will be executed
	public func execute(_ action: PortainerKit.ExecuteAction, on container: PortainerKit.Container, completionHandler: @escaping (Result<Void, Error>) -> ()) {
		logger.debug("Executing action \(action.rawValue) for containerID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else {
			completionHandler(.failure(PortainerError.noAPI))
			handle(PortainerError.noAPI)
			return
		}
		guard let endpointID = selectedEndpoint?.id else {
			completionHandler(.failure(PortainerError.noEndpoint))
			handle(PortainerError.noEndpoint)
			return
		}
		
		api.execute(action, containerID: container.id, endpointID: endpointID) { result in
			switch result {
				case .success:
					self.logger.debug("Executed action \(action.rawValue) for containerID: \(container.id), endpointID: \(endpointID).")
					completionHandler(.success(()))
				case .failure(let error):
					self.handle(error)
					completionHandler(.failure(error))
			}
		}
	}
	
	/// Fetches logs from selected container.
	/// - Parameters:
	///   - container: Get logs from this container
	///   - since: Logs since this time
	///   - tail: Number of lines
	///   - displayTimestamps: Display timestamps?
	/// - Returns: `String` logs
	public func getLogs(from container: PortainerKit.Container, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false, completionHandler: @escaping (Result<String, Error>) -> ()) {
		logger.debug("Getting logs from containerID: \(container.id), endpointID: \(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else {
			completionHandler(.failure(PortainerError.noAPI))
			handle(PortainerError.noAPI)
			return
		}
		guard let endpointID = selectedEndpoint?.id else {
			completionHandler(.failure(PortainerError.noEndpoint))
			handle(PortainerError.noEndpoint)
			return
		}
		
		api.getLogs(containerID: container.id, endpointID: endpointID, since: since, tail: tail, displayTimestamps: displayTimestamps, completionHandler: completionHandler)
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
	
	/// Handles potential errors
	/// - Parameter error: Error to handle
	private func handle(_ error: Error, _function: StaticString = #function, _fileID: StaticString = #fileID, _line: Int = #line) {
		logger.error("\(String(describing: error)) (\(_function) [\(_fileID):\(_line)])")
		
		if let error = error as? PortainerKit.APIError {
			// PortainerKit
			switch error {
				case .invalidJWTToken:
					// Check if has stored creds
					if let url = api?.url, let username = try? keychain.get(KeychainKeys.username), let password = try? keychain.get(KeychainKeys.password) {
						logger.debug("Received `invalidJWTToken`, but has credentials!")
						login(url: url, username: username, password: password, savePassword: true) { result in
							switch result {
								case .success:
									self.getEndpoints(completionHandler: { _ in })
								case .failure:
									self.logger.debug("Credentials invalid, logging out :(")
									self.logOut()
							}
						}
					}
				default:
					break
			}
		}
		
		AppState.shared.handle(error, _fileID: _fileID, _line: _line)
	}
}

private extension Portainer {
	enum KeychainKeys {
		static let token: String = "token"
		static let username: String = "username"
		static let password: String = "password"
	}
}
