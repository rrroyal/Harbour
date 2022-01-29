//
//  Portainer.swift
//  Harbour
//
//  Created by royal on 23/01/2022.
//

import Foundation
import os.log
import PortainerKit
import Keychain

public final class Portainer {
	private var api: PortainerKit? = nil
	private var endpointID: Int? = nil
	
	private let keychain: Keychain = Keychain(service: Bundle.main.mainBundleIdentifier, accessGroup: "\(Bundle.main.appIdentifierPrefix!)group.\(Bundle.main.mainBundleIdentifier)")
	private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Portainer")
	
	private init() {}
	
	public static func setup() async throws -> Portainer {
		let portainer = Portainer()
		
		guard let url = Preferences.shared.selectedServer else { throw PortainerError.noServer }
		
		guard let endpointID = Preferences.shared.selectedEndpointID else { throw PortainerError.noEndpoint }
		portainer.endpointID = endpointID

		do {
			let token = try portainer.keychain.getToken(server: url)
			portainer.api = PortainerKit(url: url, token: token)
		} catch {
			do {
				let credentials = try portainer.keychain.getCredentials(server: url)
				try await portainer.login(url: url, username: credentials.username, password: credentials.password, savePassword: true)
			} catch {
				throw error
			}

			portainer.logger.notice("No credentials, logging out [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			throw error
		}
		
		return portainer
	}
	
	public func getContainers(containerID: String? = nil) async throws -> [PortainerKit.Container] {
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }
		
		let filters: [String: [String]]?
		if let containerID = containerID {
			filters = ["id": [containerID]]
		} else {
			filters = nil
		}
		
		let containers = try await api.getContainers(for: endpointID, filters: filters ?? [:])
		logger.info("Got \(containers.count, privacy: .public) container(s) for endpointID: \(endpointID, privacy: .sensitive(mask: .hash)). [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")

		return containers
	}
	
	public func execute(_ action: PortainerKit.ExecuteAction, on containerID: String) async throws {
		guard let api = api else { throw PortainerError.noAPI }
		guard let endpointID = endpointID else { throw PortainerError.noEndpoint }

		logger.info("Executing action \"\(action.rawValue, privacy: .public)\" for containerID: \(containerID), endpointID: \(endpointID, privacy: .sensitive(mask: .hash))... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		try await api.execute(action, containerID: containerID, endpointID: endpointID)
		logger.info("Executed action \(action.rawValue, privacy: .public) for containerID: \(containerID), endpointID: \(endpointID, privacy: .sensitive(mask: .hash)). [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
	}
	
	public func checkDifferences() {
		#warning("TODO: Check differences between old and new containers and optionally send notification")
	}
	
	private func login(url: URL, username: String, password: String, savePassword: Bool) async throws {
		logger.info("Logging in with credentials, URL: \(url.absoluteString, privacy: .sensitive(mask: .hash))... [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		let api = PortainerKit(url: url)
		
		let token = try await api.login(username: username, password: password)
		
		logger.info("Successfully logged in! [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		self.api = api
		
		try keychain.saveToken(server: url, username: username, token: token, comment: Localization.KEYCHAIN_TOKEN_COMMENT.localized, hasPassword: savePassword)
		if savePassword {
			try keychain.saveCredentials(server: url, username: username, password: password, comment: Localization.KEYCHAIN_CREDS_COMMENT.localized)
		}
		
		Preferences.shared.selectedServer = url
	}
}
