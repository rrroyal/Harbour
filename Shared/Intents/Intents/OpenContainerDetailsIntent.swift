//
//  OpenContainerDetailsIntent.swift
//  Harbour
//
//  Created by royal on 11/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import Foundation
import OSLog
import UIKit

// MARK: - logger

private let logger = Logger(.intents(OpenContainerDetailsIntent.self))

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
		logger.notice("Handling in-app: \(String(describing: container), privacy: .sensitive) [\(String._debugInfo(), privacy: .public)]")
		if let url = HarbourURLScheme.containerDetails(id: container._id, displayName: container.name, endpointID: endpoint.id).url {
			await UIApplication.shared.open(url)
		}
		#endif

		return .result()
	}
}

// MARK: - OpenContainerDetailsShortcut+AppShortcutsProvider

/*
struct OpenContainerDetailsShortcut: AppShortcutsProvider {
	static var appShortcuts: [AppShortcut] {
		let containerStatusShortcut = AppShortcut(
			intent: ContainerStatusIntent(),
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
