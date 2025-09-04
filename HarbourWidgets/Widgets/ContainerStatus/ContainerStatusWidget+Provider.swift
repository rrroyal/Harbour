//
//  ContainerStatusWidget+Provider.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import OSLog
import PortainerKit
import WidgetKit

private let logger = Logger(.widgets(ContainerStatusWidget.Provider.self))

// MARK: - ContainerStatusWidget+Provider

extension ContainerStatusWidget {
	struct Provider: AppIntentTimelineProvider, Sendable {

		// MARK: Private Properties

		nonisolated(unsafe) let portainerStore = IntentPortainerStore.shared

		// MARK: AppIntentTimelineProvider

		func placeholder(in context: Context) -> Entry {
			.placeholder
		}

		func snapshot(for configuration: Intent, in context: Context) async -> Entry {
			logger.notice("Getting snapshot, isPreview: \(context.isPreview, privacy: .public)...")

			guard !context.isPreview else {
				logger.debug("Running in preview")
				return placeholder(in: context)
			}

			let entry = await getEntry(for: configuration, in: context)
			logger.info("Got entry: \(String(describing: entry), privacy: .sensitive(mask: .hash))")

			return entry
		}

		func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
			logger.notice("Getting timeline...")

			let entry = await getEntry(for: configuration, in: context)
			let timeline = Timeline<Entry>(entries: [entry], policy: .atEnd)

			logger.info("Returning timeline: \(String(describing: timeline), privacy: .sensitive(mask: .hash))")

			return .init(entries: [entry], policy: .atEnd)
		}
	}
}

// MARK: - ContainerStatusWidget.Provider+Private

private extension ContainerStatusWidget.Provider {
	func getEntry(for configuration: Intent, in context: Context) async -> Entry {
		let now = Date.now
		let configurationContainers = configuration.containers

		guard let endpoint = configuration.endpoint else {
			logger.warning("Configuration invalid, returning empty containers!")
			return Entry(date: now, configuration: configuration, result: .unconfigured)
		}

		guard !configurationContainers.isEmpty else {
			logger.warning("No configuration containers, returning empty containers!")
			return Entry(date: now, configuration: configuration, result: .containers([]))
		}

		do {
			try await portainerStore.setupIfNeeded()

			let filters = FetchFilters(
				id: configuration.resolveStrictly ? configurationContainers.map(\._id) : nil
			)
			let containers = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id, filters: filters)

			let entities: [Container?] = configurationContainers
				.map { configurationContainer in
					if let foundContainer = containers.first(where: {
						if configuration.resolveStrictly {
							configurationContainer._id == $0.id
						} else {
							configurationContainer.matchesContainer($0)
						}
					}) {
						return Container(
							id: foundContainer.id,
							names: foundContainer.names,
							image: foundContainer.image,
							labels: foundContainer.labels,
							state: foundContainer.state,
							status: foundContainer.status
						)
					}
					return nil
				}

			let entry = Entry(date: now, configuration: configuration, result: .containers(entities))
			logger.info("Returning entry: \(String(describing: entry), privacy: .sensitive)")
			return entry
		} catch {
			logger.error("Error getting entry: \(error.localizedDescription, privacy: .public)")

			if error is URLError {
				return Entry(date: now, configuration: configuration, result: .unreachable)
			} else {
				return Entry(date: now, configuration: configuration, result: .error(error))
			}
		}
	}
}
