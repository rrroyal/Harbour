//
//  ContainerStatusIntent.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
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
			}
		} otherwise: {
			Summary("Get container status on \(\.$endpoint)")
		}
	}

//	static var authenticationPolicy = IntentAuthenticationPolicy.requiresAuthentication

//	static var isDiscoverable = true

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint?

	@Parameter(
		title: "AppIntents.Parameter.Containers.Title",
		default: [],
		size: [
			.systemSmall: 1,
			.systemMedium: 2,
			.systemLarge: 4,
			.systemExtraLarge: 8
		]
	)
	var containers: [IntentContainer]

	@Parameter(
		title: "AppIntents.Parameter.ResolveByName.Title",
		description: "AppIntents.Parameter.ResolveByName.Description",
		default: false
	)
	var resolveByName: Bool

	/*
	func perform() async throws -> some IntentResult & ReturnsValue<Container> & OpensIntent {
		let containers = if let containers { containers } else { try await $containers.requestValue() }
		let endpoint: IntentEndpoint = if let endpoint { endpoint } else { try await $endpoint.requestValue() }

//		let containers = try await getContainers(
//			for: endpoint.id,
//			ids: containers.map(\._id),
//			names: containers.map(\.name),
//			resolveByName: resolveByName
//		)

//		let intentContainers = containers.map { IntentContainer(container: $0) }
		// swiftlint:disable switch_case_alignment
		let intentContainer: IntentContainer = switch intentContainers.count {
		case 0:
			throw Error.noContainers
		case 1:
			// swiftlint:disable:next force_unwrapping
			intentContainers.first!
		default:
			try await $containers.requestDisambiguation(among: intentContainers)
		}
		// swiftlint:enable switch_case_alignment

		return .result(value: intentContainer, opensIntent: OpenContainerDetailsIntent(endpoint: endpoint, container: intentContainer))
	}
	 */
}

// MARK: - ContainerStatusIntent+Error

extension ContainerStatusIntent {
	enum Error: Swift.Error {
		case noContainers
	}
}

// MARK: - ContainerStatusIntent+Private

private extension ContainerStatusIntent {
	func getContainers(for endpointID: Endpoint.ID,
					   ids: [Container.ID]? = nil,
					   names: [Container.Name?]? = nil,
					   resolveByName: Bool) async throws -> [Container] {
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
