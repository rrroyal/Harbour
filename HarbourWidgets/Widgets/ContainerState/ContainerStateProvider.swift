//
//  ContainerStateProvider.swift
//  HarbourWidgets
//
//  Created by royal on 04/10/2022.
//

import WidgetKit
import Intents
import OSLog
import PortainerKit

import UserNotifications

// TODO: Execute AppState.handleBackgroundRefresh() when providing a timeline/snapshot (inside a Task, nonblocking).

// MARK: - ContainerStateProvider

struct ContainerStateProvider: IntentTimelineProvider {
	typealias Intent = ContainerStateIntent

	private let logger = Logger(category: .containerStateIntentProvider)
	private let portainerStore = PortainerStore.shared

	static var placeholderContainer: Container {
		typealias Localization = Localizable.Widgets.Placeholder
		return Container(id: "ContainerID", names: [Localization.containerName], state: .running, status: Localization.containerStatus)
	}
	static var placeholderEntry: Entry {
		let container = Self.placeholderContainer

		let date = Date()

		let configuration = ContainerStateIntent()
		configuration.container = .init(identifier: container.id, display: container.displayName ?? container.id)

		let entry = Entry(date: date, configuration: configuration, container: container)
		return entry
	}

	func placeholder(in context: Context) -> Entry {
		logger.debug("Placeholder requested [\(String.debugInfo(), privacy: .public)]")
		return Self.placeholderEntry
	}

	func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (Entry) -> Void) {
		logger.debug("Getting snapshot, isPreview: \(context.isPreview, privacy: .public)... [\(String.debugInfo(), privacy: .public)]")

		guard !context.isPreview else {
			let placeholder = placeholder(in: context)
			completion(placeholder)
			return
		}

		let now = Date()

		guard let endpointID = Endpoint.ID(configuration.endpoint?.identifier ?? ""),
			  let intentContainer = configuration.container,
			  let containerID = intentContainer.identifier else {
			let entry = Entry(date: now, configuration: configuration, container: nil)
			completion(entry)
			return
		}

		Task {
			let entry: Entry

			do {
				try portainerStore.setupIfNeeded()

				let filters = ["id": [containerID]]
				let container = (try await portainerStore.getContainers(for: endpointID, filters: filters)).first

				entry = Entry(date: now, configuration: configuration, container: container)
			} catch {
				logger.error("Error getting a snapshot: \(error.localizedDescription, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
				entry = Entry(date: now, configuration: configuration, container: nil, error: error)
			}

			completion(entry)
		}
	}

	func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
		logger.debug("Getting timeline... [\(String.debugInfo(), privacy: .public)]")

		let now = Date()

//		#if DEBUG
//		let debugNotification = UNMutableNotificationContent()
//		debugNotification.title = "🚧 getTimeline() request"
//		debugNotification.threadIdentifier = "debug"
//		let debugNotificationIdentifier = "Debug.WidgetTimeline.Request.\(now.timeIntervalSince1970)"
//		let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: nil)
//		UNUserNotificationCenter.current().add(debugNotificationRequest) { _ in }
//		#endif

		guard let endpointID = Endpoint.ID(configuration.endpoint?.identifier ?? ""),
			  let intentContainer = configuration.container,
			  let containerID = intentContainer.identifier else {
			let entry = Entry(date: now, configuration: configuration, container: nil)
			let timeline = Timeline(entries: [entry], policy: .atEnd)
			completion(timeline)
			return
		}

		Task {
			let entry: Entry

			do {
				try portainerStore.setupIfNeeded()

				let filters = ["id": [containerID]]
				let container = (try await portainerStore.getContainers(for: endpointID, filters: filters)).first

				entry = Entry(date: now, configuration: configuration, container: container)
			} catch {
				logger.error("Error getting a timeline: \(error.localizedDescription, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
				entry = Entry(date: now, configuration: configuration, container: nil, error: error)
			}

//			#if DEBUG
//			let debugNotification = UNMutableNotificationContent()
//			debugNotification.title = "🚧 getTimeline() completion"
//			debugNotification.threadIdentifier = "debug"
//			debugNotification.body = [
//				entry.error?.localizedDescription ?? "no error",
//				entry.container?.id ?? "no container"
//			].joined(separator: "\n")
//			let debugNotificationIdentifier = "Debug.WidgetTimeline.Return.\(now.timeIntervalSince1970)"
//			let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: nil)
//			UNUserNotificationCenter.current().add(debugNotificationRequest) { _ in }
//			#endif

			let timeline = Timeline(entries: [entry], policy: .atEnd)
			completion(timeline)
		}
	}
}

// MARK: - ContainerStateProvider+Entry

extension ContainerStateProvider {
	struct Entry: TimelineEntry {
		let date: Date
		let configuration: ContainerStateIntent
		let container: Container?
		let error: Error?

		init(date: Date,
			 configuration: ContainerStateIntent,
			 container: Container? = nil,
			 error: Error? = nil) {
			self.date = date
			self.configuration = configuration
			self.container = container
			self.error = error
		}
	}
}
