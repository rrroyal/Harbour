//
//  ContainerActionIntent.swift
//  Harbour
//
//  Created by royal on 09/07/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import PortainerKit

// MARK: - ContainerActionIntent

struct ContainerActionIntent: AppIntent {
	static let title: LocalizedStringResource = "ContainerActionIntent.Title"
	static let description = IntentDescription("ContainerActionIntent.Description")

	static var parameterSummary: some ParameterSummary {
		When(\.$containerAction, .hasAnyValue) {
			When(\.$endpoint, .hasAnyValue) {
				Summary("ContainerActionIntent.ParameterSummary.Simple \(\.$containerAction) \(\.$container)") {
					\.$endpoint
				}
			} otherwise: {
				Summary("ContainerActionIntent.ParameterSummary \(\.$containerAction)") {
					\.$endpoint
				}
			}
		} otherwise: {
			When(\.$endpoint, .hasAnyValue) {
				Summary("ContainerActionIntent.ParameterSummary.Complex \(\.$containerAction) \(\.$container)") {
					\.$endpoint
				}
			} otherwise: {
				Summary("ContainerActionIntent.ParameterSummary \(\.$containerAction)") {
					\.$endpoint
				}
			}
		}
	}

	static let authenticationPolicy = IntentAuthenticationPolicy.requiresAuthentication

	static let isDiscoverable = true

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint

	@Parameter(title: "AppIntents.Parameter.Container.Title")
	var container: IntentContainer

	@Parameter(title: "AppIntents.Parameter.ContainerAction.Title")
	var containerAction: ContainerActionAppEnum

	init() { }

	init(endpoint: IntentEndpoint, container: IntentContainer, containerAction: ContainerAction) {
		self.endpoint = endpoint
		self.container = container
		self.containerAction = .init(action: containerAction)
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentContainer> {
		let portainerStore = IntentPortainerStore.shared
		try portainerStore.setupIfNeeded()
		try await portainerStore.execute(containerAction.portainerAction, containerID: container._id, endpointID: endpoint.id)

		let newContainer = try await portainerStore.getContainers(for: endpoint.id, filters: .init(id: [container._id])).first
		guard let newContainer else {
			throw Error.containerNotFound(container._id)
		}

//		let dialogDescription = if let status = newContainer.status {
//			"\(newContainer.state.description.localizedCapitalized) (\(status))"
//		} else {
//			newContainer.state.description
//		}
//		return .result(
//			value: .init(container: newContainer),
//			dialog: .init(
//				full: .init(stringLiteral: dialogDescription),
//				systemImageName: newContainer.state.icon
//			)
//		)
		return .result(value: .init(container: newContainer))
	}
}

// MARK: - ContainerActionIntent+Error

extension ContainerActionIntent {
	enum Error: Swift.Error, LocalizedError {
		case containerNotFound(Container.ID)

		var errorDescription: String? {
			switch self {
			case .containerNotFound(let containerID):
				String(localized: "ContainerActionIntent.Error.ContainerNotFound ID:\(containerID)")
			}
		}
	}
}
