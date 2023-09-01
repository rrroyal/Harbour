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
		logger.info("Getting snapshot, isPreview: \(context.isPreview, privacy: .public)... [\(String._debugInfo(), privacy: .public)]")

		guard !context.isPreview else {
			logger.debug("Running in preview. [\(String._debugInfo(), privacy: .public)]")
			return placeholder(in: context)
		}

		let entry = await getEntry(for: configuration, in: context)
		logger.debug("Got entry: \(String(describing: entry), privacy: .sensitive(mask: .hash)). [\(String._debugInfo(), privacy: .public)]")

		return entry
	}

	func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
		logger.info("Getting timeline... [\(String._debugInfo(), privacy: .public)]")

		let entry = await getEntry(for: configuration, in: context)
		logger.debug("Got entry: \(String(describing: entry), privacy: .sensitive(mask: .hash)). [\(String._debugInfo(), privacy: .public)]")

		return .init(entries: [entry], policy: .atEnd)
	}
}

// MARK: - ContainerStatusProvider+Entry

extension ContainerStatusProvider {
	struct Entry: TimelineEntry {
		enum Result {
			case containers([Container])
			case error(Error)
			case unreachable
		}

		// swiftlint:disable force_unwrapping
		static var placeholder: Self {
			let intentEndpoint = IntentEndpoint.preview()

			let intentContainer1 = IntentContainer.preview(id: "1")
			let intentContainer2 = IntentContainer.preview(id: "2")
			let intentContainer3 = IntentContainer.preview(id: "3")
			let intentContainers = [intentContainer1, intentContainer2, intentContainer3]

			let date = Date(timeIntervalSince1970: 1584296700)

			let intent = ContainerStatusProvider.Intent()
			intent.endpoint = intentEndpoint
			intent.containers = intentContainers

			let container1 = Container(
				id: "1",
				names: [intentContainer1.name!],
				state: .running,
				status: String(localized: "IntentContainer.Preview.Status")
			)
			let container2 = Container(
				id: "2",
				names: [intentContainer2.name!],
				state: .paused,
				status: String(localized: "IntentContainer.Preview.Status")
			)
			let containers = [container1, container2]

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
				let containerScore: Float = switch container.state {
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
		let containers = configuration.containers

		guard let endpoint = configuration.endpoint, !containers.isEmpty else {
			let entry = Entry(date: now, configuration: configuration, result: .containers([]))
			return entry
		}

		do {
			try portainerStore.setupIfNeeded()

			let filters = Portainer.FetchFilters(
				id: configuration.resolveByName ? nil : containers.map(\._id),
				name: configuration.resolveByName ? containers.compactMap(\.name) : nil
			)
			let _containers = try await portainerStore.getContainers(for: endpoint.id, filters: filters)

			// Remake containers to make the payload smaller
			let containers = _containers.map {
				Container(id: $0.id, names: $0.names, state: $0.state, status: $0.status)
			}

			return Entry(date: now, configuration: configuration, result: .containers(containers))
		} catch {
			logger.error("Error getting containers: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")

			if error is URLError {
				return Entry(date: now, configuration: configuration, result: .unreachable)
			}

			return Entry(date: now, configuration: configuration, result: .error(error))
		}
	}
}
