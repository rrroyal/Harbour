//
//  ContainerStatusWidget+Intent.swift
//  Harbour
//
//  Created by royal on 04/07/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import AppIntents
import OSLog
import PortainerKit

private let logger = Logger(.intents(ContainerStatusWidget.Intent.self))

// MARK: - ContainerStatusWidget+Intent

extension ContainerStatusWidget {
	struct Intent: WidgetConfigurationIntent {
		static let title: LocalizedStringResource = "ContainerStatusWidget.Intent.Title"

		@Parameter(title: "AppIntents.Parameter.Endpoint.Title")
		var endpoint: IntentEndpoint?

		@Parameter(
			title: "AppIntents.Parameter.Containers.Title",
			default: [],
			size: [
				.accessoryInline: 1,
				.accessoryRectangular: 1,
				.systemSmall: 1,
				.systemMedium: 2,
				.systemLarge: 4,
				.systemExtraLarge: 8
			]
		)
		var containers: [IntentContainer]

		@Parameter(
			title: "AppIntents.Parameter.ResolveStrictly.Title",
			description: "AppIntents.Parameter.ResolveStrictly.Description",
			default: false
		)
		var resolveStrictly: Bool

		init() { }

		init(endpoint: IntentEndpoint, containers: [IntentContainer]) {
			self.endpoint = endpoint
			self.containers = containers
		}
	}
}
