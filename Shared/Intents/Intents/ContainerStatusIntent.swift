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
	static let description = IntentDescription("ContainerStatusIntent.Description")

	static var parameterSummary: some ParameterSummary {
		When(\.$endpoint, .hasAnyValue) {
			Summary("ContainerStatusIntent.ParameterSummary \(\.$endpoint) \(\.$containers)") {
				\.$resolveByName
			}
		} otherwise: {
			Summary("ContainerStatusIntent.ParameterSummary \(\.$endpoint)")
		}
	}

	static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

	static let isDiscoverable = false

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint?

	@Parameter(
		title: "AppIntents.Parameter.Containers.Title",
		size: [
			.systemSmall: 1,
			.systemMedium: 2,
			.systemLarge: 4
		]
	)
	var containers: [IntentContainer]?

	@Parameter(
		title: "AppIntents.Parameter.ResolveByName.Title",
		description: "AppIntents.Parameter.ResolveByName.Description",
		default: true
	)
	var resolveByName: Bool

	init() {
		self.endpoint = nil
		self.containers = nil
	}

	init(endpoint: IntentEndpoint? = nil, containers: [IntentContainer]?) {
		self.endpoint = endpoint
		self.containers = containers
	}

	@MainActor
	func perform() async throws -> some ReturnsValue<IntentContainer> {
		do {
			guard let endpoint else {
				throw $endpoint.needsValueError()
			}
			guard let containers, !containers.isEmpty else {
				throw $containers.needsValueError()
			}

			let portainerStore = IntentPortainerStore.shared
			try portainerStore.setupIfNeeded()

			let filters = FetchFilters(
				id: resolveByName ? nil : containers.map(\._id),
				name: resolveByName ? containers.compactMap(\.name) : nil
			)
			let newContainers = try await portainerStore.getContainers(for: endpoint.id, filters: filters)
				.map { IntentContainer(container: $0) }

			let newContainer: IntentContainer = switch newContainers.count {
			case 0:
				throw Error.noContainers
			case 1:
				// swiftlint:disable:next force_unwrapping
				containers.first!
			default:
				try await $containers.requestDisambiguation(among: containers)
			}

			return .result(value: newContainer)
		} catch {
			logger.error("Error performing: \(error, privacy: .public)")
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
