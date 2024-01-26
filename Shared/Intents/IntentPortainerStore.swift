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

private let logger = Logger(.custom(IntentPortainerStore.self))

// MARK: - IntentPortainerStore

public final class IntentPortainerStore: @unchecked Sendable {
	static let shared = IntentPortainerStore()

	// swiftlint:disable:next force_unwrapping
	private let keychain = Keychain(accessGroup: Bundle.main.groupIdentifier!)
	private let portainer = Portainer(urlSessionConfiguration: .backgroundTasks)
	private let preferences = Preferences.shared

	public private(set) var isSetup = false

	private init() {
		try? setupIfNeeded()
	}

	public func setupIfNeeded() throws {
		isSetup = false

		guard let urlStr = preferences.selectedServer else {
			throw PortainerError.noServer
		}
		guard let url = URL(string: urlStr) else {
			throw GenericError.invalidURL
		}
		if isSetup && portainer.serverURL == url { return }

		let token = try keychain.getString(for: url)
		portainer.setup(url: url, token: token)

		isSetup = true
	}

	public func getEndpoints() async throws -> [Endpoint] {
//		logger.info("Getting endpoints...")
		do {
			let endpoints = try await portainer.fetchEndpoints()
//			logger.debug("Got \(endpoints.count, privacy: .public) endpoints")
			return endpoints.sorted()
		} catch {
			logger.error("Failed to get endpoints: \(error, privacy: .public)")
			throw error
		}
	}

	public func getContainers(for endpointID: Endpoint.ID, filters: Portainer.FetchFilters? = nil) async throws -> [Container] {
//		logger.info("Getting containers...")
		do {
			let containers = try await portainer.fetchContainers(endpointID: endpointID, filters: filters)
//			logger.debug("Got \(containers.count, privacy: .public) containers")
			return containers.sorted()
		} catch {
			logger.error("Failed to get containers: \(error, privacy: .public)")
			throw error
		}
	}

	public func execute(_ action: ExecuteAction, containerID: Container.ID, endpointID: Endpoint.ID) async throws {
		logger.notice("Executing action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\"...")
		do {
			try await portainer.execute(action, containerID: containerID, endpointID: endpointID)

			logger.notice("Executed action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\"")
		} catch {
			logger.error("Failed to execute action \"\(action.rawValue, privacy: .public)\" on container with ID: \"\(containerID, privacy: .public)\": \(error, privacy: .public)")
			throw error
		}
	}
}
