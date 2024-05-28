//
//  ExecuteActionIntent.swift
//  Harbour
//
//  Created by royal on 09/07/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import PortainerKit

// MARK: - ExecuteActionIntent

struct ExecuteActionIntent: AppIntent {
	static var title: LocalizedStringResource = "ExecuteActionIntent.Title"
	static var description = IntentDescription("ExecuteActionIntent.Description")

	static var parameterSummary: some ParameterSummary {
		When(\.$endpoint, .hasAnyValue) {
			Summary("Execute \(\.$action) on \(\.$container)") {
				\.$endpoint
			}
		} otherwise: {
			Summary("Execute \(\.$action) on a container") {
				\.$endpoint
			}
		}
	}

	static var authenticationPolicy = IntentAuthenticationPolicy.requiresAuthentication

	static var isDiscoverable = true

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint

	@Parameter(title: "AppIntents.Parameter.Container.Title")
	var container: IntentContainer

	@Parameter(title: "AppIntents.Parameter.ExecuteAction.Title")
	var action: ContainerAction	// this breaks because `ContainerAction` is defined in a framework :(

	init() { }

	init(endpoint: IntentEndpoint, container: IntentContainer, action: ContainerAction) {
		self.endpoint = endpoint
		self.container = container
		self.action = action
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		let portainerStore = IntentPortainerStore.shared
		try await portainerStore.execute(action, containerID: container.id, endpointID: endpoint.id)
		return .result()
	}
}

// MARK: - ExecuteActionIntent+AppShortcutsProvider

extension ExecuteActionIntent: AppShortcutsProvider {
	static var appShortcuts: [AppShortcut] = [
		.init(
			intent: Self(),
			phrases: [
				"ExecuteActionIntent.Phrases.ExecuteAction"
			],
			shortTitle: "ExecuteActionIntent.Title",
			systemImageName: "questionmark"
		)
	]
}
