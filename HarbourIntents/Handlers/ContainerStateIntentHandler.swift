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
import CommonFoundation
import CommonOSLog

// TODO: Try to implement this in AppIntents?

// MARK: - ContainerStateIntentHandler

/// Handler for `ContainerStateIntent`
final class ContainerStateIntentHandler: NSObject, ContainerStateIntentHandling {

	private let logger = Logger(category: Logger.Category.intents)
	private let portainerStore = PortainerStore.shared

	override init() {
		super.init()
		try? portainerStore.setupIfNeeded()
	}

	/// Provides options for `endpoint` parameter.
	func provideEndpointOptionsCollection(for intent: ContainerStateIntent, searchTerm: String?) async throws -> INObjectCollection<IntentEndpoint> {
		logger.debug("Providing options for \"endpoint\" [\(String._debugInfo(), privacy: .public)]...")

		let endpoints = try await portainerStore.getEndpoints()

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
		logger.debug("Providing options for \"container\" [\(String._debugInfo(), privacy: .public)]...")

		guard let endpointID = Int(intent.endpoint?.identifier ?? "") else {
			return .init(items: [])
		}

		let containers = try await portainerStore.fetchContainers(for: endpointID)
		let items: [IntentContainer] = containers
			.filtered(searchTerm ?? "")
			.sorted()
			.map {
				let intentContainer = IntentContainer(identifier: $0.id, display: $0.displayName ?? $0.id)
				intentContainer.name = $0.names?.first
				return intentContainer
			}
		return .init(items: items)
	}

	/// Resolves value for `endpoint` parameter.
	func resolveEndpoint(for intent: ContainerStateIntent) async -> IntentEndpointResolutionResult {
		logger.debug("Resolving endpoint with ID: \(intent.endpoint?.identifier ?? "<none>", privacy: .public) [\(String._debugInfo(), privacy: .public)]...")

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
		logger.debug("Resolving container with ID: \(intent.container?.identifier ?? "<none>", privacy: .public) [\(String._debugInfo(), privacy: .public)]...")

		guard let endpointID = Int(intent.endpoint?.identifier ?? ""),
			  let intentContainer = intent.container else { return .needsValue() }

		do {
			let resolveByName = intent.resolveByName?.boolValue ?? false
			let filters = PortainerStore.filters(for: intentContainer.identifier,
												 name: intentContainer.name,
												 resolveByName: resolveByName)
			let containers = try await portainerStore.fetchContainers(for: endpointID, filters: filters)
			switch containers.count {
			case 0:
				return .needsValue()
			case 1:
				guard let firstContainer = containers.first else {
					return .needsValue()
				}
				let intentContainer = IntentContainer(identifier: firstContainer.id, display: firstContainer.displayName ?? firstContainer.id)
				intentContainer.name = firstContainer.names?.first
				return .success(with: intentContainer)
			case 2...:
				let intentContainers = containers
					.sorted()
					.map {
						let intentContainer = IntentContainer(identifier: $0.id, display: $0.displayName ?? $0.id)
						intentContainer.name = $0.names?.first
						return intentContainer
					}
				return .disambiguation(with: intentContainers)
			default:
				return .needsValue()
			}
		} catch {
			return .needsValue()
		}
	}

	/// Resolves value for `resolveByName` parameter.
	func resolveResolveByName(for intent: ContainerStateIntent) async -> INBooleanResolutionResult {
		.success(with: intent.resolveByName?.boolValue ?? false)
	}

	/// Handles `ContainerStateIntent`.
	func handle(intent: ContainerStateIntent) async -> ContainerStateIntentResponse {
		logger.notice("Handling intent with containerID: \(intent.container?.identifier ?? "<none>", privacy: .public) [\(String._debugInfo(), privacy: .public)]...")

		do {
			guard let endpointID = Endpoint.ID(intent.endpoint?.identifier ?? ""),
				  let intentContainer = intent.container else {
				throw IntentError.noConfigurationSelected
			}

			let resolveByName = intent.resolveByName?.boolValue ?? false
			let filters = PortainerStore.filters(for: intentContainer.identifier,
												 name: intentContainer.name,
												 resolveByName: resolveByName)
			let containers = try await portainerStore.fetchContainers(for: endpointID, filters: filters)
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
