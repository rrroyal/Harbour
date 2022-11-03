//
//  ContainerStateIntentHandler.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//

import Foundation
import Intents
import OSLog
import PortainerKit

// TODO: Try to implement this in AppIntents?

// MARK: - ContainerStateIntentHandler

/// Handler for `ContainerStateIntent`
final class ContainerStateIntentHandler: NSObject, ContainerStateIntentHandling {

	private let logger = Logger(category: .containerStateIntentHandler)
	private let portainerStore = PortainerStore.shared

	/// Cached endpoints
	private var endpoints: [Endpoint]?

	/// Cached containers
	private var containers: [Endpoint.ID: [Container]] = [:]

	override init() {
		super.init()
		try? portainerStore.setupIfNeeded()
	}

	/// Provides options for `endpoint` parameter.
	func provideEndpointOptionsCollection(for intent: ContainerStateIntent, searchTerm: String?) async throws -> INObjectCollection<IntentEndpoint> {
		logger.debug("Providing options for \"endpoint\" [\(String.debugInfo(), privacy: .public)]...")

		let endpoints = try await fetchEndpoints()

		let items: [IntentEndpoint] = endpoints
			.filter {
				guard let searchTerm else { return true }
				return ($0.name ?? "").localizedCaseInsensitiveContains(searchTerm)
			}
			.sorted()
			.map {
				let endpoint = IntentEndpoint(identifier: "\($0.id)", display: $0.name ?? $0.id.description)
				return endpoint
			}

		return .init(items: items)
	}

	/// Provides options for `container` parameter.
	func provideContainerOptionsCollection(for intent: ContainerStateIntent, searchTerm: String?) async throws -> INObjectCollection<IntentContainer> {
		logger.debug("Providing options for \"container\" [\(String.debugInfo(), privacy: .public)]...")

		guard let endpointID = Int(intent.endpoint?.identifier ?? "") else {
			return .init(items: [])
		}

		let containers = try await fetchContainers(for: endpointID)

		let items: [IntentContainer] = containers
			.filtered(query: searchTerm ?? "")
			.sorted()
			.map { IntentContainer(identifier: $0.id, display: $0.displayName ?? $0.id) }

		return .init(items: items)
	}

	/// Resolves value for `endpoint` parameter.
	func resolveEndpoint(for intent: ContainerStateIntent) async -> IntentEndpointResolutionResult {
		logger.debug("Resolving endpoint with ID: \(intent.endpoint?.identifier ?? "<none>", privacy: .public) [\(String.debugInfo(), privacy: .public)]...")

		guard let endpointID = Int(intent.endpoint?.identifier ?? "") else { return .needsValue() }

		do {
			let endpoints = try await portainerStore.getEndpoints()
			let endpointsFiltered = endpoints.filter { $0.id == endpointID }

			switch endpointsFiltered.count {
				case 0:
					return .needsValue()
				case 1:
					guard let firstEndpoint = endpointsFiltered.first else {
						return .needsValue()
					}
					let intentEndpoint = IntentEndpoint(identifier: "\(firstEndpoint.id)",
														display: firstEndpoint.name ?? firstEndpoint.id.description)
					return .success(with: intentEndpoint)
				case 2...:
					let intentEndpoints: [IntentEndpoint] = endpointsFiltered
						.sorted()
						.map { IntentEndpoint(identifier: "\($0.id)", display: $0.name ?? $0.id.description) }
					return .disambiguation(with: intentEndpoints)
				default:
					return .needsValue()
			}
		} catch {
			return .needsValue()
		}
	}

	/// Resolves value for `container` parameter.
	func resolveContainer(for intent: ContainerStateIntent) async -> IntentContainerResolutionResult {
		logger.debug("Resolving container with ID: \(intent.container?.identifier ?? "<none>", privacy: .public) [\(String.debugInfo(), privacy: .public)]...")

		guard let endpointID = Int(intent.endpoint?.identifier ?? ""),
			  let containerID = intent.container?.identifier else { return .needsValue() }

		do {
			let containers = try await getContainers(for: endpointID, with: containerID)
			switch containers.count {
				case 0:
					return .needsValue()
				case 1:
					guard let firstContainer = containers.first else {
						return .needsValue()
					}
					let intentContainer = IntentContainer(identifier: firstContainer.id, display: firstContainer.displayName ?? firstContainer.id)
					return .success(with: intentContainer)
				case 2...:
					let intentContainers = containers
						.sorted()
						.map { IntentContainer(identifier: $0.id, display: $0.displayName ?? $0.id) }
					return .disambiguation(with: intentContainers)
				default:
					return .needsValue()
			}
		} catch {
			return .needsValue()
		}
	}

	/// Handles `ContainerStateIntent`.
	func handle(intent: ContainerStateIntent) async -> ContainerStateIntentResponse {
		logger.debug("Handling intent with containerID: \(intent.container?.identifier ?? "<none>", privacy: .public) [\(String.debugInfo(), privacy: .public)]...")

		do {
			guard let endpointID = Int(intent.endpoint?.identifier ?? ""),
				  let intentContainer = intent.container,
				  let containerID = intentContainer.identifier else { throw IntentError.noConfigurationSelected }

			let containers = try await getContainers(for: endpointID, with: containerID)
			guard let container = containers.first else {
				throw IntentError.noValueForConfiguration
			}

			let state = IntentContainerState(containerState: container.state)
			let status = container.status
			return .success(state: state, status: status ?? Localizable.Generic.unknown, containerName: container.displayName ?? intentContainer.displayString)
		} catch {
			let containerName = intent.container?.displayString ?? Localizable.Generic.unknown
			return .failure(error: error.localizedDescription, containerName: containerName)
		}
	}
}

// MARK: - ContainerStateIntentHandler+private

private extension ContainerStateIntentHandler {
	func fetchEndpoints() async throws -> [Endpoint] {
		if let storedEndpoints = self.endpoints {
			return storedEndpoints
		} else {
			try portainerStore.setupIfNeeded()
			let endpoints = try await portainerStore.getEndpoints()
			self.endpoints = endpoints
			return endpoints
		}
	}

	/// Fetches containers, or returns cached ones if available.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: `[Container]`
	func fetchContainers(for endpointID: Endpoint.ID) async throws -> [Container] {
		if let storedContainers = self.containers[endpointID] {
			return storedContainers
		} else {
			try portainerStore.setupIfNeeded()
			let containers = try await portainerStore.getContainers(for: endpointID)
			self.containers[endpointID] = containers
			return containers
		}
	}

	/// Fetches containers with specified `containerID`.
	/// - Parameter containerID: ID to filter for
	/// - Returns: `[Container]` with `id == containerID`
	func getContainers(for endpointID: Endpoint.ID, with containerID: String) async throws -> [Container] {
		try portainerStore.setupIfNeeded()
		let filters = ["id": [containerID]]
		return try await portainerStore.getContainers(for: endpointID, filters: filters)
	}
}
