//
//  ContainerStatusIntent.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import PortainerKit

// MARK: - ContainerStatusIntent

struct ContainerStatusIntent: AppIntent, WidgetConfigurationIntent {
	static var title: LocalizedStringResource = "ContainerStatusIntent.Title"
	static var description = IntentDescription("ContainerStatusIntent.Description")

	static var parameterSummary: some ParameterSummary {
		When(\.$endpoint, .hasAnyValue) {
			Summary("Get container status on \(\.$endpoint)") {
				\.$containers
				\.$resolveByName
				\.$resolveOffline
			}
		} otherwise: {
			Summary("Get container status on \(\.$endpoint)")
		}
	}

	static var authenticationPolicy = IntentAuthenticationPolicy.requiresAuthentication

//	static var isDiscoverable = true

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint?

	@Parameter(
		title: "AppIntents.Parameter.Containers.Title",
		default: [],
		size: [
			.systemSmall: 1,
			.systemMedium: 2,
			.systemLarge: 4
		]
	)
	var containers: [IntentContainer]

	@Parameter(
		title: "AppIntents.Parameter.ResolveByName.Title",
		description: "AppIntents.Parameter.ResolveByName.Description",
		default: false
	)
	var resolveByName: Bool

	@Parameter(
		title: "AppIntents.Parameter.ResolveOffline.Title",
		description: "AppIntents.Parameter.ResolveOffline.Description",
		default: false
	)
	var resolveOffline: Bool

	init() {
		self.endpoint = nil
		self.containers = []
	}

	init(endpoint: IntentEndpoint? = nil, containers: [IntentContainer]) {
		self.endpoint = endpoint
		self.containers = containers
	}

	@MainActor
	func perform() async throws -> some OpensIntent & ReturnsValue<IntentContainer> {
		guard let endpoint else { throw $containers.needsValueError()}
		guard !containers.isEmpty else { throw $containers.needsValueError() }

		// swiftlint:disable switch_case_alignment
		let intentContainer: IntentContainer = switch containers.count {
		case 0:
			throw Error.noContainers
		case 1:
			// swiftlint:disable:next force_unwrapping
			containers.first!
		default:
			try await $containers.requestDisambiguation(among: containers)
		}
		// swiftlint:enable switch_case_alignment

		return .result(value: intentContainer, opensIntent: OpenContainerDetailsIntent(endpoint: endpoint, container: intentContainer))
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

// MARK: - ContainerStatusIntent+Private

private extension ContainerStatusIntent {
	func getContainers(
		for endpointID: Endpoint.ID,
		ids: [Container.ID]? = nil,
		names: [Container.Name?]? = nil,
		resolveByName: Bool
	) async throws -> [Container] {
		let portainerStore = IntentPortainerStore.shared
		try portainerStore.setupIfNeeded()

		let filters = IntentPortainerStore.filters(
			for: ids,
			names: names,
			resolveByName: resolveByName
		)
		let containers = try await portainerStore.getContainers(for: endpointID, filters: filters)
		return containers
	}
}

// MARK: - ContainerStatusIntent+AppShortcutsProvider

/*
extension ContainerStatusIntent: AppShortcutsProvider {
	static var appShortcuts: [AppShortcut] {
		let containerStatusShortcut = AppShortcut(
			intent: Self(),
			phrases: [
				"Get container status in \(.applicationName)",
				"Check container in \(.applicationName)"
			],
			shortTitle: "ContainerStatusIntent-ShortTitle",
			systemImageName: "xmark"
		)

		return [containerStatusShortcut]
	}
}
*/
