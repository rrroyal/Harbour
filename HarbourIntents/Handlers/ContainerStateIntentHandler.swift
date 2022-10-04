//
//  ContainerStateIntentHandler.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//

import Foundation
import Intents
import os.log
import PortainerKit

// TODO: Try to implement this in AppIntents?

// MARK: - ContainerStateIntentHandler

/// Handler for `ContainerStateIntent`
final class ContainerStateIntentHandler: NSObject, ContainerStateIntentHandling {

	private let logger = Logger(category: "ContainerStatusIntentHandler")
	private let portainerStore = PortainerStore.shared

	/// Cached containers
	private var containers: [Container]?

	override init() {
		super.init()
		try? portainerStore.setupIfNeeded()
	}

	/// Provides options for `container` parameter.
	func provideContainerOptionsCollection(for intent: ContainerStateIntent, searchTerm: String?) async throws -> INObjectCollection<IntentContainer> {
		logger.debug("Providing options for \"container\" [\(String.debugInfo(), privacy: .public)]...")

		let containers = try await fetchContainers()

		let items: [IntentContainer] = containers
			.filtered(query: searchTerm ?? "")
			.sorted()
			.map { IntentContainer(identifier: $0.id, display: $0.displayName ?? $0.id) }

		return .init(items: items)
	}

	/// Resolves value for `container` parameter.
	func resolveContainer(for intent: ContainerStateIntent) async -> IntentContainerResolutionResult {
		logger.debug("Resolving container with ID: \(intent.container?.identifier ?? "<none>", privacy: .public) [\(String.debugInfo(), privacy: .public)]...")

		guard let containerID = intent.container?.identifier else { return .needsValue() }

		do {
			let containers = try await getContainers(with: containerID)
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
			guard let containerID = intent.container?.identifier else { throw IntentError.noConfigurationSelected }

			let containers = try await getContainers(with: containerID)
			guard let container = containers.first else {
				throw IntentError.noValueForConfiguration
			}

			let state = IntentContainerState(containerState: container.state)
			let status = container.status
			return .success(state: state, status: status ?? Localizable.Generic.unknown)
		} catch {
			return .failure(error: error.localizedDescription)
		}
	}
}

// MARK: - ContainerStateIntentHandler+private

private extension ContainerStateIntentHandler {
	/// Fetches containers, or returns cached ones if available.
	/// - Returns: `[Container]`
	func fetchContainers() async throws -> [Container] {
		if let storedContainers = self.containers {
			return storedContainers
		} else {
			try portainerStore.setupIfNeeded()
			let containers = try await portainerStore.getContainers()
			self.containers = containers
			return containers
		}
	}

	/// Fetches containers with specified `containerID`.
	/// - Parameter containerID: ID to filter for
	/// - Returns: `[Container]` with `id == containerID`
	func getContainers(with containerID: String) async throws -> [Container] {
		try portainerStore.setupIfNeeded()
		let filters = ["id": [containerID]]
		return try await portainerStore.getContainers(filters: filters)
	}
}
