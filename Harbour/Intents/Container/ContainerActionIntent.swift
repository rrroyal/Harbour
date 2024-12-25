//
//  ContainerActionIntent.swift
//  Harbour
//
//  Created by royal on 09/07/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import CommonOSLog
import OSLog
import PortainerKit

private let logger = Logger(.intents(ContainerActionIntent.self))

// MARK: - ContainerActionIntent

struct ContainerActionIntent: AppIntent {
	static let title: LocalizedStringResource = "ContainerActionIntent.Title"
	static let description = IntentDescription(
		"ContainerActionIntent.Description",
		categoryName: "IntentCategory.Containers",
		resultValueName: "IntentContainer.TypeDisplayRepresentation"
	)

	static var parameterSummary: some ParameterSummary {
		When(\.$containerAction, .hasAnyValue) {
			When(\.$endpoint, .hasAnyValue) {
				Summary("ContainerActionIntent.Summary.Simple \(\.$containerAction) \(\.$container)") {
					\.$endpoint
				}
			} otherwise: {
				Summary("ContainerActionIntent.Summary.Simple \(\.$containerAction)") {
					\.$endpoint
				}
			}
		} otherwise: {
			When(\.$endpoint, .hasAnyValue) {
				Summary("ContainerActionIntent.Summary.Verbose \(\.$containerAction) \(\.$container)") {
					\.$endpoint
				}
			} otherwise: {
				Summary("ContainerActionIntent.Summary.Verbose \(\.$containerAction)") {
					\.$endpoint
				}
			}
		}
	}

	static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

	static let isDiscoverable = true

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint?

	@Parameter(title: "AppIntents.Parameter.Container.Title")
	var container: IntentContainer?

	@Parameter(title: "AppIntents.Parameter.ContainerAction.Title")
	var containerAction: ContainerActionAppEnum?

	init() { }

	init(endpoint: IntentEndpoint, container: IntentContainer, containerAction: ContainerAction) {
		self.endpoint = endpoint
		self.container = container
		self.containerAction = .init(action: containerAction)
	}

	func perform() async throws -> some ReturnsValue<IntentContainer?> {
		logger.info("Performing \(Self.self)...")

		do {
			let portainerStore = IntentPortainerStore.shared
			try await portainerStore.setupIfNeeded()

			let endpoint: IntentEndpoint
			if let _endpoint = self.endpoint {
				endpoint = _endpoint
			} else {
				endpoint = try await self.$endpoint.requestValue()
			}

			let container: IntentContainer
			if let _container = self.container {
				container = _container
			} else {
//				container = try await self.$container.requestValue() // this doesn't work :)
				let containers = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id)
					.sorted()
					.map { IntentContainer(container: $0) }
				container = try await $container.requestDisambiguation(
					among: containers,
					dialog: .init(IntentContainer.typeDisplayRepresentation.name)
				)
			}

			let containerAction: ContainerActionAppEnum
			if let _containerAction = self.containerAction {
				containerAction = _containerAction
			} else {
				let acceptableActions = ContainerAction.actionsForState(container.containerState?.portainerState)
					.localizedSorted(by: \.title)
					.map { ContainerActionAppEnum(action: $0) }
				containerAction = try await self.$containerAction.requestDisambiguation(
					among: acceptableActions,
					dialog: .init(ContainerActionAppEnum.typeDisplayRepresentation.name)
				)
			}

			// swiftlint:disable:next line_length
			logger.notice("Performing \(Self.self, privacy: .public), endpoint: \(endpoint.id, privacy: .sensitive(mask: .hash)), container: \(container._id, privacy: .sensitive(mask: .hash)), action: \(containerAction.rawValue, privacy: .public)...")

			try await portainerStore.portainer.executeContainerAction(containerAction.portainerAction, containerID: container._id, endpointID: endpoint.id)

			let newContainer = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id, filters: .init(id: [container._id])).first
			guard let newContainer else {
				return .result(value: nil)
//				throw PortainerError.containerNotFound(container._id)
			}
			let newIntentContainer = IntentContainer(container: newContainer)

			logger.info("Returning \(String(describing: newIntentContainer)).")
			return .result(value: newIntentContainer)
		} catch {
			logger.error("Failed to perform \(Self.self, privacy: .public): \(error.localizedDescription, privacy: .public)")
			throw error
		}
	}
}
