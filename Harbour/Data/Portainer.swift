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
	public static let shared: Portainer = Portainer()
	
	@Published public var isLoggedIn: Bool = false
	@AppStorage(UserDefaults.Keys.endpointURL) var endpointURL: String?
	
	public let refreshCurrentContainer: PassthroughSubject<Void, Never> = .init()
	@Published public var selectedEndpoint: PortainerKit.Endpoint? = nil {
		didSet {
			if let endpointID = self.selectedEndpoint?.id {
				async { await getContainers(endpointID: endpointID) }
			} else {
				self.containers = []
			}
		}
	}

	@Published public var endpoints: [PortainerKit.Endpoint] = [] {
		didSet {
			if endpoints.count == 1 {
				self.selectedEndpoint = endpoints.first
			} else if endpoints.isEmpty {
				self.selectedEndpoint = nil
			}
		}
	}
	
	@Published public var containers: [PortainerKit.Container] = []
	
	private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "Harbour").Portainer", category: "Portainer")
	private let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "Harbour").label("Harbour").synchronizable(true).accessibility(.afterFirstUnlock)
	private let ud: UserDefaults = Preferences.shared.ud
	private var api: PortainerKit?
	
	private init() {
		self.logger.debug("init()")
		
		// swiftlint:disable indentation_width
		if let urlString = self.endpointURL,
		   let url = URL(string: urlString),
		   let token = keychain[urlString] {
			self.logger.debug("Initializing PortainerKit for URL=\(url, privacy: .sensitive)")
			self.api = PortainerKit(url: url, token: token)
			async { await self.getEndpoints() }
		}
	}
	
	public func login(url: URL, username: String, password: String) async -> Result<Void, Error> {
		self.logger.debug("Logging in! URL=\(url.absoluteString, privacy: .sensitive) username=\(username, privacy: .sensitive) password=\(password, privacy: .private)")
		let api = PortainerKit(url: url)
		self.api = api
		
		let result = await api.login(username: username, password: password)
		switch result {
			case .success(let token):
				self.logger.debug("Successfully logged in!")
				
				DispatchQueue.main.async {
					self.endpointURL = url.absoluteString
				}
				
				self.keychain[url.absoluteString] = token
				await getEndpoints()
				
				return .success(())
				
			case .failure(let error):
				self.logger.error("\(String(describing: error))")
				return .failure(error)
		}
	}
	
	public func logOut() {
		if let urlString = self.endpointURL {
			try? self.keychain.remove(urlString)
		}
		self.ud.removeObject(forKey: UserDefaults.Keys.endpointURL)
		self.isLoggedIn = false
	}
	
	@discardableResult
	public func getEndpoints() async -> Result<[PortainerKit.Endpoint], Error> {
		self.logger.debug("Getting endpoints...")
		
		guard let api = self.api else { return .failure(PortainerError.noAPI) }
		
		let result = await api.getEndpoints()
		switch result {
			case .success(let endpoints):
				self.logger.debug("Got \(endpoints.count) endpoint(s).")
				DispatchQueue.main.async {
					self.endpoints = endpoints
					self.isLoggedIn = true
				}
				return .success(endpoints)
			case .failure(let error):
				self.logger.error("\(String(describing: error))")
				DispatchQueue.main.async {
					self.endpoints = []
					
					if let error = error as? PortainerKit.APIError, error == .invalidJWTToken {
						self.isLoggedIn = false
					}
				}
				return .failure(error)
		}
	}
	
	@discardableResult
	public func getContainers(endpointID: Int) async -> Result<[PortainerKit.Container], Error> {
		self.logger.debug("Getting containers for endpointID=\(endpointID)...")
		
		guard let api = self.api else { return .failure(PortainerError.noAPI) }

		let result = await api.getContainers(for: endpointID)
		switch result {
			case .success(let containers):
				self.logger.debug("Got \(containers.count) container(s).")
				DispatchQueue.main.async {
					self.containers = containers
				}
				return .success(containers)
			case .failure(let error):
				self.logger.error("\(String(describing: error))")
				DispatchQueue.main.async {
					self.containers = []
				}
				return .failure(error)
		}
	}
	
	public func inspectContainer(id containerID: String) async -> Result<PortainerKit.ContainerDetails, Error> {
		self.logger.debug("Inspecting container with ID=\(containerID), endpointID=\(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = self.api else { return .failure(PortainerError.noAPI) }
		guard let endpointID = self.selectedEndpoint?.id else { return .failure(PortainerError.noEndpoint) }

		let result = await api.inspectContainer(containerID, endpointID: endpointID)
		switch result {
			case .success(let containerDetails):
				self.logger.debug("Got details for containerID=\(containerID), endpointID=\(endpointID).")
				return .success(containerDetails)
			case .failure(let error):
				self.logger.error("\(String(describing: error))")
				return .failure(error)
		}
	}
	
	@discardableResult
	public func execute(_ action: PortainerKit.ExecuteAction, containerID: String) async -> Result<Void, Error> {
		self.logger.debug("Executing action \(action.rawValue) for containerID=\(containerID), endpointID=\(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = self.api else { return .failure(PortainerError.noAPI) }
		guard let endpointID = self.selectedEndpoint?.id else { return .failure(PortainerError.noEndpoint) }
		
		let result = await api.execute(action, containerID: containerID, endpointID: endpointID)
		switch result {
			case .success():
				self.logger.debug("Executed action \(action.rawValue) for containerID=\(containerID), endpointID=\(endpointID).")
				return .success(())
			case .failure(let error):
				self.logger.error("\(String(describing: error))")
				return .failure(error)
		}
	}

	public func attach(to containerID: String) -> Result<PortainerKit.WebSocketPassthroughSubject, Error> {
		self.logger.debug("Attaching to containerID=\(containerID), endpointID=\(self.selectedEndpoint?.id ?? -1)...")
		
		guard let api = self.api else { return .failure(PortainerError.noAPI) }
		guard let endpointID = self.selectedEndpoint?.id else { return .failure(PortainerError.noEndpoint) }
		
		self.logger.debug("Connected to containerID=\(containerID), endpointID=\(self.selectedEndpoint?.id ?? -1)!")
		return api.attach(to: containerID, endpointID: endpointID)
	}
}

extension Portainer {
	enum PortainerError: Error {
		case noAPI
		case noEndpoint
		case noResponse
	}
}
