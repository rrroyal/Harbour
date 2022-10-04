//
//  PortainerStore.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//

import Foundation
import os.log
import PortainerKit
import KeychainKit

public final class PortainerStore {
	static let shared = PortainerStore()

	private let logger = Logger(category: "PortainerStore")
	private let keychain = Keychain(accessGroup: Bundle.main.groupIdentifier)
	private let portainer = Portainer()
	private let preferences = Preferences.shared

	public var isSetup: Bool {
		portainer.isSetup
	}

	private init() {
		try? setupIfNeeded()
	}

	public func setupIfNeeded() throws {
		guard !isSetup else { return }

		guard let urlStr = preferences.selectedServer else {
			throw PortainerError.noServer
		}
		guard let url = URL(string: urlStr) else {
			throw GenericError.invalidURL
		}

		let token = try keychain.getToken(for: url)
		portainer.setup(url: url, token: token)
	}

	public func getContainers(filters: [String: [String]] = [:]) async throws -> [Container] {
		guard isSetup else {
			throw PortainerError.notSetup
		}
		guard let endpointID = Preferences.shared.selectedEndpointID else {
			throw PortainerError.noSelectedEndpoint
		}
		return try await portainer.fetchContainers(endpointID: endpointID, filters: filters)
	}

}
