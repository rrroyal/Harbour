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
import CommonOSLog

public final class PortainerStore {
	static let shared = PortainerStore()

	private let logger = Logger(category: Logger.Category.portainerStore)
	// swiftlint:disable:next force_unwrapping
	private let keychain = Keychain(accessGroup: Bundle.main.groupIdentifier!)
	private let portainer = Portainer(urlSessionConfiguration: .intents)
	private let preferences = Preferences.shared

	private(set) var endpoints: [Endpoint]?
	private(set) var containers: [Endpoint.ID: [Container]] = [:]

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

		let token = try keychain.getContent(for: url)
		portainer.setup(url: url, token: token)
	}

	public func getEndpoints() async throws -> [Endpoint] {
		if let storedEndpoints = self.endpoints {
			return storedEndpoints
		} else {
			try setupIfNeeded()
			let endpoints = try await fetchEndpoints()
			self.endpoints = endpoints
			return endpoints
		}
	}

	/// Fetches containers, or returns cached ones if available.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: `[Container]`
	public func getContainers(for endpointID: Endpoint.ID) async throws -> [Container] {
		if let storedContainers = self.containers[endpointID] {
			return storedContainers
		} else {
			try setupIfNeeded()
			let containers = try await fetchContainers(for: endpointID)
			self.containers[endpointID] = containers
			return containers
		}
	}

	public func fetchContainers(for endpointID: Endpoint.ID, filters: [String: [String]] = [:]) async throws -> [Container] {
		guard isSetup else {
			throw PortainerError.notSetup
		}
		return try await portainer.fetchContainers(endpointID: endpointID, filters: filters)
	}
}

// MARK: - PortainerStore+Static

public extension PortainerStore {
	static func filters(for containerID: Container.ID?, name containerName: String?, resolveByName: Bool) -> [String: [String]] {
		let filters: [String: [String]] = [
			"id": resolveByName ? [] : [containerID ?? ""],
			"name": resolveByName ? [containerName ?? ""] : []
		]
		return filters
	}
}

// MARK: - PortainerStore+Private

private extension PortainerStore {
	func fetchEndpoints() async throws -> [Endpoint] {
		guard isSetup else {
			throw PortainerError.notSetup
		}
		return try await portainer.fetchEndpoints()
	}
}
