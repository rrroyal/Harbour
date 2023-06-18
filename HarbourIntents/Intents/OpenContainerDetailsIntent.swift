//
//  OpenContainerDetailsIntent.swift
//  Harbour
//
//  Created by royal on 11/06/2023.
//

import Foundation
import AppIntents

// MARK: - OpenContainerDetailsIntent

struct OpenContainerDetailsIntent: AppIntent {
	static var title: LocalizedStringResource = "OpenContainerDetailsIntent.Title"
	static var description = IntentDescription("OpenContainerDetailsIntent.Description")

	static var parameterSummary: some ParameterSummary {
		When(\.$endpoint, .hasAnyValue) {
			Summary("Open container details") {
				\.$endpoint
				\.$container
			}
		} otherwise: {
			Summary("Open container details on \(\.$endpoint)")
		}
	}

	static var isDiscoverable = true

	static var openAppWhenRun = true

	@Parameter(title: "OpenContainerDetailsIntent.Parameter.Endpoint")
	var endpoint: IntentEndpoint?

	@Parameter(title: "OpenContainerDetailsIntent.Parameter.Container")
	var container: IntentContainer

	init(endpoint: IntentEndpoint?, container: IntentContainer) {
		self.endpoint = endpoint
		self.container = container
	}

	init() {}

	func perform() async throws -> some IntentResult {
		.result()
	}
}

// MARK: - OpenContainerDetailsShortcut

// TODO: AppShortcut

/*
struct OpenContainerDetailsShortcut: AppShortcutsProvider {
	static var appShortcuts: [AppShortcut] {
		let containerStatusShortcut = AppShortcut(
			intent: ContainerStatusIntent(),
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
