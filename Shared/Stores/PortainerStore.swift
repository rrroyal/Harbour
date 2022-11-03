//
//  PortainerStore.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//

import Foundation
import OSLog
import PortainerKit
import KeychainKit

public final class PortainerStore {
	static let shared = PortainerStore()

	private let logger = Logger(category: .portainerStore)
	private let keychain = Keychain(accessGroup: Bundle.main.groupIdentifier)
	private let portainer: Portainer
	private let preferences = Preferences.shared

	public var isSetup: Bool {
		portainer.isSetup
	}

	private init() {
		self.portainer = Portainer(urlSessionConfiguration: .harbourBackground)
		try? setupIfNeeded()
	}

	public func setupIfNeeded() throws {
		guard let urlStr = preferences.selectedServer else {
			throw PortainerError.noServer
		}
		guard let url = URL(string: urlStr) else {
			throw GenericError.invalidURL
		}
		if isSetup && portainer.serverURL == url { return }

		let token = try keychain.getToken(for: url)
		portainer.setup(url: url, token: token)
	}

	public func getEndpoints() async throws -> [Endpoint] {
		guard isSetup else {
			throw PortainerError.notSetup
		}
		return try await portainer.fetchEndpoints()
	}

	public func getContainers(for endpointID: Endpoint.ID, filters: [String: [String]] = [:]) async throws -> [Container] {
		guard isSetup else {
			throw PortainerError.notSetup
		}
		return try await portainer.fetchContainers(endpointID: endpointID, filters: filters)
	}

}
