//
//  ContainerStatusProvider.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import OSLog
import PortainerKit
import WidgetKit

private let logger = Logger(.widgets(ContainerStatusProvider.self))

// MARK: - ContainerStatusProvider

struct ContainerStatusProvider: AppIntentTimelineProvider {
	typealias Intent = ContainerStatusIntent

	// MARK: Private Properties

	private let portainerStore = IntentPortainerStore.shared

	// MARK: AppIntentTimelineProvider

	func placeholder(in context: Context) -> Entry {
		.placeholder
	}

	func snapshot(for configuration: Intent, in context: Context) async -> Entry {
		logger.info("Getting snapshot, isPreview: \(context.isPreview, privacy: .public)...")

		guard !context.isPreview else {
			logger.debug("Running in preview")
			return placeholder(in: context)
		}

		let entry = await getEntry(for: configuration, in: context)
		logger.debug("Got entry: \(String(describing: entry), privacy: .sensitive(mask: .hash))")

		return entry
	}

	func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
		logger.info("Getting timeline...")

		let entry = await getEntry(for: configuration, in: context)
		logger.debug("Got entry: \(String(describing: entry), privacy: .sensitive(mask: .hash))")

		return .init(entries: [entry], policy: .atEnd)
	}
}

// MARK: - ContainerStatusProvider+Entry

extension ContainerStatusProvider {
	struct Entry: TimelineEntry {
		enum Result {
			case unconfigured
			case containers([Container?])
			case error(Error)
			case unreachable
		}

		// swiftlint:disable force_unwrapping
		static var placeholder: Self {
			let intentEndpoint = IntentEndpoint.preview()

			let intentContainer1 = IntentContainer.preview(id: "1")
			let intentContainer2 = IntentContainer.preview(id: "2")
			let intentContainer3 = IntentContainer.preview(id: "3")
			let intentContainer4 = IntentContainer.preview(id: "4")
			let intentContainers = [intentContainer1, intentContainer2, intentContainer3, intentContainer4]

			let date = Date(timeIntervalSince1970: 1584296700)

			let intent = ContainerStatusProvider.Intent()
			intent.endpoint = intentEndpoint
			intent.containers = intentContainers

			let container1 = Container(
				id: intentContainer1._id,
				names: [intentContainer1.name!],
				state: .running,
				status: String(localized: "IntentContainer.Preview.Status")
			)
			let container2 = Container(
				id: intentContainer2._id,
				names: [intentContainer2.name!],
				state: .paused,
				status: String(localized: "IntentContainer.Preview.Status")
			)
			let container3 = Container(
				id: intentContainer3._id,
				names: [intentContainer3.name!],
				state: .restarting,
				status: String(localized: "IntentContainer.Preview.Status")
			)
			let container4 = Container(
				id: intentContainer4._id,
				names: [intentContainer4.name!],
				state: .exited,
				status: String(localized: "IntentContainer.Preview.Status")
			)
			let containers = [container1, container2, container3, container4]

			return .init(
				date: date,
				configuration: intent,
				result: .containers(containers),
				isPlaceholder: true
			)
		}
		// swiftlint:enable force_unwrapping

		let date: Date
		let configuration: ContainerStatusProvider.Intent
		let result: Result
		var isPlaceholder = false

		var relevance: TimelineEntryRelevance? {
			guard case .containers(let containers) = self.result else {
				return .init(score: 0)
			}

			let score: Float = containers.reduce(into: 0) { absoluteScore, container in
				// swiftlint:disable switch_case_alignment
				let containerScore: Float = switch container?.state {
				case .none:				0.0
				case .running:			0.1
				case .paused:			0.2
				case .exited:			0.3
				case .created:			0.4
				case .removing:			0.4
				case .restarting:		0.5
				case .dead:				0.6
				}
				// swiftlint:enable switch_case_alignment
				absoluteScore += containerScore
			}
			return .init(score: score)
		}
	}
}

// MARK: - ContainerStatusProvider+Private

private extension ContainerStatusProvider {
	func getEntry(for configuration: Intent, in context: Context) async -> Entry {
		let now = Date.now
		let configurationContainers = configuration.containers

		guard let endpoint = configuration.endpoint else {
			logger.notice("Configuration invalid, returning empty containers!")
			return Entry(date: now, configuration: configuration, result: .unconfigured)
		}

		guard let configurationContainers, !configurationContainers.isEmpty else {
			logger.notice("No configuration containers, returning empty containers!")
			return Entry(date: now, configuration: configuration, result: .containers([]))
		}

		do {
			try portainerStore.setupIfNeeded()

			let filters = Portainer.FetchFilters(
				id: configuration.resolveStrictly ? configurationContainers.map(\._id) : nil
			)
			let containers = try await portainerStore.getContainers(for: endpoint.id, filters: filters)

			let entities: [Container?] = configurationContainers
				.map { configurationContainer in
					if let foundContainer = containers.first(where: {
						if configuration.resolveStrictly {
							return configurationContainer._id == $0.id
						} else {
							return configurationContainer.matchesContainer($0)
						}
					}) {
						return Container(
							id: foundContainer.id,
							names: foundContainer.names,
							imageID: foundContainer.imageID,
							labels: foundContainer.labels,
							state: foundContainer.state,
							status: foundContainer.status
						)
					}
					return nil
				}

			logger.notice("Returning \(String(describing: entities), privacy: .sensitive)")
			return Entry(date: now, configuration: configuration, result: .containers(entities))
		} catch {
			logger.error("Error getting entry: \(error, privacy: .public)")

			if error is URLError {
				return Entry(date: now, configuration: configuration, result: .unreachable)
			}

			return Entry(date: now, configuration: configuration, result: .error(error))
		}
	}
}
