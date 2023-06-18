//
//  ContainerStatusIntent.swift
//  HarbourIntents
//
//  Created by royal on 10/06/2023.
//

import AppIntents

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

	@Parameter(title: "ContainerStatusIntent.Parameter.Endpoint")
	var endpoint: IntentEndpoint?

	// TODO: Make sure that it limits selection
	@Parameter(
		title: "ContainerStatusIntent.Parameter.Containers",
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
		title: "ContainerStatusIntent.Parameter.ResolveByName",
		description: "ContainerStatusIntent.Parameter.ResolveByName.Description",
		default: false
	)
	var resolveByName: Bool

	/*
	func perform() async throws -> some IntentResult {
		return .result(value: IntentContainer(id: "", name: nil))
	}
	 */
}

// MARK: - ContainerStatusIntent+AppShortcutsProvider

/*
extension ContainerStatusIntent: AppShortcutsProvider {
	static var appShortcuts: [AppShortcut] {
		let containerStatusShortcut = AppShortcut(
			intent: Self(),
			phrases: [
				// TODO: Localization
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
