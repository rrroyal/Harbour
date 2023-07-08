//
//  OpenContainerDetailsIntent.swift
//  Harbour
//
//  Created by royal on 11/06/2023.
//

import AppIntents
import Foundation
import OSLog

// MARK: - OpenContainerDetailsIntent

struct OpenContainerDetailsIntent: AppIntent {
	static var title: LocalizedStringResource = "OpenContainerDetailsIntent.Title"
	static var description = IntentDescription("OpenContainerDetailsIntent.Description")

	static var parameterSummary: some ParameterSummary {
		When(\.$endpoint, .hasAnyValue) {
			Summary("Open \(\.$container) details on \(\.$endpoint)")
		} otherwise: {
			Summary("Open container details on \(\.$endpoint)")
		}
	}

//	static var isDiscoverable = true

	static var openAppWhenRun = true

	@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
	var endpoint: IntentEndpoint

	@Parameter(title: "AppIntents.Parameter.Container.Title")
	var container: IntentContainer

	init() { }

	init(endpoint: IntentEndpoint, container: IntentContainer) {
		self.endpoint = endpoint
		self.container = container
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		#if TARGET_APP
		Logger(category: Logger.Category.intents).notice("PERFORMING INTENT APP endpoint: \(endpoint.id); container: \(container.id)")
		AppState.shared.alertContent = "Endpoint: \(endpoint.id)\nContainer: \(container.id)"

		if let url = HarbourURLScheme.containerDetails(id: container._id, displayName: container.name, endpointID: endpoint.id).url {

		}
		#else
		Logger(category: Logger.Category.intents).notice("PERFORMING INTENT ELSE endpoint: \(endpoint.id); container: \(container.id)")
		#endif

		return .result()
	}
}

// MARK: - OpenContainerDetailsShortcut+AppShortcutsProvider

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
