//
//  ContainerStatusIntent.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import OSLog
import PortainerKit

private let logger = Logger(.intents(ContainerStatusIntent.self))

// MARK: - ContainerStatusIntent

struct ContainerStatusIntent: AppIntent, WidgetConfigurationIntent {
	static let title: LocalizedStringResource = "ContainerStatusIntent.Title"
	static let description = IntentDescription(
		"ContainerStatusIntent.Description",
		categoryName: "IntentCategory.Containers"
	)

	static var parameterSummary: some ParameterSummary {
		When(\.$endpoint, .hasAnyValue) {
			Summary("ContainerStatusIntent.ParameterSummary \(\.$endpoint) \(\.$container)") {
				\.$resolveStrictly
			}
		} otherwise: {
			Summary("ContainerStatusIntent.ParameterSummary \(\.$endpoint)")
		}
	}

	static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

	static let isDiscoverable = true

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint?

	@Parameter(title: "AppIntents.Parameter.Container.Title")
	var container: IntentContainer?

	@Parameter(
		title: "AppIntents.Parameter.ResolveStrictly.Title",
		description: "AppIntents.Parameter.ResolveStrictly.Description",
		default: false
	)
	var resolveStrictly: Bool

	init() { }

	init(endpoint: IntentEndpoint, container: IntentContainer) {
		self.endpoint = endpoint
		self.container = container
	}

	func perform() async throws -> some ReturnsValue<IntentContainer> {
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

			var filters = FetchFilters()
			if let _container = self.container {
				if !resolveStrictly, let name = _container.name {
					filters.name = [name]
				} else {
					filters.id = [_container._id]
				}
			}
			let fetchedContainers = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id, filters: filters)
				.map { IntentContainer(container: $0) }
				.localizedSorted(by: \.name)

			let fetchedContainer: IntentContainer = switch fetchedContainers.count {
			case 0:
				throw Error.noContainers
			case 1:
				// swiftlint:disable:next force_unwrapping
				fetchedContainers.first!
			default:
				try await $container.requestDisambiguation(among: fetchedContainers, dialog: .init(IntentContainer.typeDisplayRepresentation.name))
			}

			logger.info("Returning \(String(describing: fetchedContainer)).")
			return .result(value: fetchedContainer)
		} catch {
			logger.error("Failed to perform \(Self.self, privacy: .public): \(error.localizedDescription, privacy: .public)")
			throw error
		}
	}
}

// MARK: - ContainerStatusIntent+Error

extension ContainerStatusIntent {
	enum Error: LocalizedError {
		case noContainers

		var errorDescription: String? {
			switch self {
			case .noContainers:
				String(localized: "ContainerStatusIntent.Error.NoContainers")
			}
		}
	}
}
