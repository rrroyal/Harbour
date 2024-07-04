//
//  ContainerStatusWidget+Entry.swift
//  Harbour
//
//  Created by royal on 04/07/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import WidgetKit

extension ContainerStatusWidget {
	struct Entry: TimelineEntry {
		enum Result: Identifiable {
			case unconfigured
			case containers([Container?])
			case unreachable
			case error(Error)

			var id: Int {
				switch self {
				case .unconfigured:
					-1
				case .containers:
					-2
				case .unreachable:
					-3
				case .error:
					-4
				}
			}
		}

		// swiftlint:disable force_unwrapping
		static var placeholder: Self {
			let intentEndpoint = IntentEndpoint.preview()

			let intentContainer1 = IntentContainer.preview(id: "1")
			let intentContainer2 = IntentContainer.preview(id: "2")
			let intentContainer3 = IntentContainer.preview(id: "3")
			let intentContainer4 = IntentContainer.preview(id: "4")
			let intentContainers = [intentContainer1, intentContainer2, intentContainer3, intentContainer4]

			let date = Date.now

			let intent = ContainerStatusWidget.Intent()
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
		let configuration: ContainerStatusWidget.Intent
		let result: Result
		var isPlaceholder = false

		var relevance: TimelineEntryRelevance? {
			guard case .containers(let containers) = self.result else {
				return .init(score: 0)
			}

			let score: Float = containers.reduce(into: 0) { absoluteScore, container in
				let containerScore: Float = switch container?.state {
				case .none:				0.0
				case .running, .exited:	0.1
				case .paused, .dead:	0.2
				case .created:			0.3
				case .removing:			0.4
				case .restarting:		0.5
				}
				absoluteScore += containerScore
			}
			return .init(score: score)
		}
	}
}
