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
	@AppStorage(UserDefaults.Key.endpointURL) var endpointURL: String?
	
	// MARK: Endpoint
	
	@Published public var selectedEndpoint: PortainerKit.Endpoint? = nil {
		didSet {
			if let endpointID = selectedEndpoint?.id {
				async { await getContainers(endpointID: endpointID) }
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
	
	public let refreshCurrentContainer: PassthroughSubject<Void, Never> = .init()
	@Published public private(set) var containers: [PortainerKit.Container] = []
	@Published public private(set) var attachedContainer: AttachedContainer? = nil
	
	// MARK: - Private properties
	
	private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "Harbour").Portainer", category: "Portainer")
	private let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "Harbour").label("Harbour").synchronizable(true).accessibility(.afterFirstUnlock)
	private let ud: UserDefaults = Preferences.shared.ud
	private var api: PortainerKit?
	
	// MARK: - init
	
	private init() {
		logger.debug("init()")
		
		if let urlString = endpointURL,
		   let url = URL(string: urlString),
		   let token = keychain[urlString] {
			logger.debug("Initializing PortainerKit for URL=\(url, privacy: .sensitive)")
			api = PortainerKit(url: url, token: token)
			async { await getEndpoints() }
		}
	}
	
	// MARK: - Public functions
	
	/// Logs in to Portainer.
	/// - Parameters:
	///   - url: Endpoint URL
	///   - username: Username
	///   - password: Password
	/// - Returns: Result containing JWT token or error.
	public func login(url: URL, username: String, password: String) async -> Result<Void, Error> {
		logger.debug("Logging in! URL=\(url.absoluteString, privacy: .sensitive) username=\(username, privacy: .sensitive) password=\(password, privacy: .private)")
		let api = PortainerKit(url: url)
		self.api = api
		
		let result = await api.login(username: username, password: password)
		switch result {
			case .success(let token):
				logger.debug("Successfully logged in!")
				
				DispatchQueue.main.async { [weak self] in
					self?.endpointURL = url.absoluteString
				}
				
				keychain[url.absoluteString] = token
				await getEndpoints()
				
				return .success(())
				
			case .failure(let error):
				logger.error("\(String(describing: error))")
				return .failure(error)
		}
	}
	
	/// Logs out, removing all local authentication.
	public func logOut() {
		logger.info("Logging out")
		if let urlString = endpointURL {
			try? keychain.remove(urlString)
		}
		isLoggedIn = false
		endpointURL = nil
		selectedEndpoint = nil
		endpoints = []
		containers = []
		attachedContainer = nil
	}
	
	/// Fetches available endpoints.
	/// - Returns: Result containing `[PortainerKit.Endpoint]` or error.
	@discardableResult
	public func getEndpoints() async -> Result<[PortainerKit.Endpoint], Error> {
		logger.debug("Getting endpoints...")
		
		guard let api = api else { return .failure(PortainerError.noAPI) }
		
		let result = await api.getEndpoints()
		switch result {
			case .success(let endpoints):
				logger.debug("Got \(endpoints.count) endpoint(s).")
				DispatchQueue.main.async { [weak self] in
					self?.endpoints = endpoints
					self?.isLoggedIn = true
				}
				return .success(endpoints)
			case .failure(let error):
				logger.error("\(String(describing: error))")
				DispatchQueue.main.async { [weak self] in
					self?.endpoints = []
					
					if let error = error as? PortainerKit.APIError, error == .invalidJWTToken {
						self?.isLoggedIn = false
					}
				}
				return .failure(error)
		}
	}
	
	/// Fetches available containers for selected endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: Result containing `[PortainerKit.Container]` or error.
	@discardableResult
	public func getContainers(endpointID: Int) async -> Result<[PortainerKit.Container], Error> {
		logger.debug("Getting containers for endpointID=\(endpointID)...")
		
		guard let api = api else { return .failure(PortainerError.noAPI) }

		let result = await api.getContainers(for: endpointID)
		switch result {
			case .success(let containers):
				logger.debug("Got \(containers.count) container(s) for endpointID=\(endpointID).")
				DispatchQueue.main.async { [weak self] in
					self?.containers = containers
				}
				return .success(containers)
			case .failure(let error):
				logger.error("\(String(describing: error))")
				DispatchQueue.main.async { [weak self] in
					self?.containers = []
				}
				return .failure(error)
		}
	}
	
	/// Fetches container details.
	/// - Parameter container: Container to be inspected
	/// - Returns: Result containing `PortainerKit.ContainerDetails` or error.
	public func inspectContainer(_ container: PortainerKit.Container) async -> Result<PortainerKit.ContainerDetails, Error> {
		logger.debug("Inspecting container with ID=\(container.id), endpointID=\(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { return .failure(PortainerError.noAPI) }
		guard let endpointID = selectedEndpoint?.id else { return .failure(PortainerError.noEndpoint) }

		let result = await api.inspectContainer(container.id, endpointID: endpointID)
		switch result {
			case .success(let containerDetails):
				logger.debug("Got details for containerID=\(container.id), endpointID=\(endpointID).")
				return .success(containerDetails)
			case .failure(let error):
				logger.error("\(String(describing: error))")
				return .failure(error)
		}
	}
	
	/// Executes an action on selected container.
	/// - Parameters:
	///   - action: Action to be executed
	///   - container: Container, where the action will be executed
	/// - Returns: Result containing void or error.
	@discardableResult
	public func execute(_ action: PortainerKit.ExecuteAction, on container: PortainerKit.Container) async -> Result<Void, Error> {
		logger.debug("Executing action \(action.rawValue) for containerID=\(container.id), endpointID=\(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { return .failure(PortainerError.noAPI) }
		guard let endpointID = selectedEndpoint?.id else { return .failure(PortainerError.noEndpoint) }
		
		let result = await api.execute(action, containerID: container.id, endpointID: endpointID)
		switch result {
			case .success():
				logger.debug("Executed action \(action.rawValue) for containerID=\(container.id), endpointID=\(endpointID).")
				return .success(())
			case .failure(let error):
				logger.error("\(String(describing: error))")
				return .failure(error)
		}
	}
	
	/// Fetches logs from selected container.
	/// - Parameters:
	///   - container: Get logs from this container
	///   - since: Logs since this time
	///   - tail: Number of lines
	///   - displayTimestamps: Display timestamps?
	/// - Returns: Result containing `String` logs or error.
	public func getLogs(from container: PortainerKit.Container, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false) async -> Result<String, Error> {
		logger.debug("Getting logs from containerID=\(container.id), endpointID=\(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { return .failure(PortainerError.noAPI) }
		guard let endpointID = selectedEndpoint?.id else { return .failure(PortainerError.noEndpoint) }
		
		let result = await api.getLogs(containerID: container.id, endpointID: endpointID, since: since, tail: tail, displayTimestamps: displayTimestamps)
		logger.debug("Got logs from containerID=\(container.id), endpointID=\(self.selectedEndpoint?.id ?? -1)!")
		switch result {
			case .success(let logs):
				return .success(logs)
			case .failure(let error):
				logger.error("\(String(describing: error))")
				return .failure(error)
		}
	}
	
	/// Attaches to container through a WebSocket connection.
	/// - Parameter container: Container to attach to
	/// - Returns: Result containing `AttachedContainer` or error.
	@discardableResult
	public func attach(to container: PortainerKit.Container) -> Result<AttachedContainer, Error> {
		if let attachedContainer = attachedContainer, attachedContainer.container.id == container.id {
			return .success(attachedContainer)
		}
		
		logger.debug("Attaching to containerID=\(container.id), endpointID=\(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = api else { return .failure(PortainerError.noAPI) }
		guard let endpointID = selectedEndpoint?.id else { return .failure(PortainerError.noEndpoint) }
		
		logger.debug("Attached to containerID=\(container.id), endpointID=\(self.selectedEndpoint?.id ?? -1)!")
		let result = api.attach(to: container.id, endpointID: endpointID)
		switch result {
			case .success(let messagePassthroughSubject):
				let attachedContainer = AttachedContainer(container: container, messagePassthroughSubject: messagePassthroughSubject)
				self.attachedContainer = attachedContainer
				return .success(attachedContainer)
			case .failure(let error):
				return .failure(error)
		}
	}
}
