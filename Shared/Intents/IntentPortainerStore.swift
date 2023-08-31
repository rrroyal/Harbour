//
//  IntentPortainerStore.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonOSLog
import Foundation
import KeychainKit
import OSLog
import PortainerKit

private let logger = Logger(.intents(IntentPortainerStore.self))

// MARK: - IntentPortainerStore

public final class IntentPortainerStore: @unchecked Sendable {
	static let shared = IntentPortainerStore()

	// swiftlint:disable:next force_unwrapping
	private let keychain = Keychain(accessGroup: Bundle.main.groupIdentifier!)
	private let portainer = Portainer(urlSessionConfiguration: .intents)
	private let preferences = Preferences.shared

	public var isSetup: Bool {
		portainer.isSetup
	}

	private init() {
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

		let token = try keychain.getString(for: url)
		portainer.setup(url: url, token: token)
	}

	public func getEndpoints() async throws -> [Endpoint] {
		logger.info("Getting endpoints... [\(String._debugInfo(), privacy: .public)]")
		do {
			let endpoints = try await portainer.fetchEndpoints()
			logger.debug("Got \(endpoints.count, privacy: .public) endpoints [\(String._debugInfo(), privacy: .public)]")
			return endpoints.sorted()
		} catch {
			logger.error("Failed to get endpoints: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	public func getContainers(for endpointID: Endpoint.ID, filters: Portainer.ContainersFilters = [:]) async throws -> [Container] {
		logger.info("Getting containers... [\(String._debugInfo(), privacy: .public)]")
		do {
			let containers = try await portainer.fetchContainers(endpointID: endpointID, filters: filters)
			logger.debug("Got \(containers.count, privacy: .public) containers [\(String._debugInfo(), privacy: .public)]")
			return containers.sorted()
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}

	public func execute(_ action: ExecuteAction, containerID: Container.ID, endpointID: Endpoint.ID) async throws {
		// swiftlint:disable:next line_length
		logger.notice("Executing action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\"... [\(String._debugInfo(), privacy: .public)]")
		do {
			try await portainer.execute(action, containerID: containerID, endpointID: endpointID)

			logger.debug("Executed action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")
		} catch {
			// swiftlint:disable:next line_length
			logger.error("Failed to execute action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\": \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			throw error
		}
	}
}

// MARK: - IntentPortainerStore+Static

public extension IntentPortainerStore {
	static func filters(for containerIDs: [Container.ID]?, names containerNames: [Container.Name?]?, resolveByName: Bool) -> Portainer.ContainersFilters {
		let filters: Portainer.ContainersFilters = [
			"id": resolveByName ? [] : (containerIDs ?? []),
			"name": resolveByName ? (containerNames?.compactMap { $0 } ?? []) : []
		]
		return filters
	}
}
