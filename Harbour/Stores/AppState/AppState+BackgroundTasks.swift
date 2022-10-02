//
//  AppState+BackgroundTasks.swift
//  Harbour
//
//  Created by royal on 01/10/2022.
//

import Foundation
import BackgroundTasks
import UserNotifications
import PortainerKit

// MARK: - AppState+scheduleBackgroundRefresh

extension AppState {

	func scheduleBackgroundRefresh() {
		logger.info("Scheduling background refresh with identifier: \"\(HarbourBackgroundTask.backgroundRefresh, privacy: .public)\"... [\(String.debugInfo(), privacy: .public)]")

		let request = BGAppRefreshTaskRequest(identifier: HarbourBackgroundTask.backgroundRefresh)
		request.earliestBeginDate = .now

		#if DEBUG
		let debugNotification = UNMutableNotificationContent()
		debugNotification.title = "🚧 Background refresh scheduled!"
		let debugNotificationIdentifier = "Debug.BackgroundRefreshScheduled"
		let debugNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: debugNotificationTrigger)
		UNUserNotificationCenter.current().add(debugNotificationRequest, withCompletionHandler: { _ in })
		#endif

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			// swiftlint:disable:next line_length
			logger.error("Error scheduling background task with identifier: \"\(request.identifier, privacy: .public)\": \(String(describing: error), privacy: .public) [\(String.debugInfo(), privacy: .public)]")
		}
	}

}

// MARK: - AppState+handleBackgroundRefresh

extension AppState {

	private enum AppRefreshContainerChange {
		case disappeared(name: String)
		case stateChanged(name: String, from: ContainerState?, to: ContainerState?)
	}

	private static let containersChangedNotificationIdentifier = "ContainersChanged"

	@Sendable
	nonisolated func handleBackgroundRefresh() async {
		do {
			logger.info("Handling background refresh... [\(String.debugInfo(), privacy: .public)]")

			#if DEBUG
			Preferences.shared.lastBackgroundRefreshDate = Date().timeIntervalSince1970
			#endif

			// Schedule new background refresh
			scheduleBackgroundRefresh()

			// Get pre-refresh containers
			let storedContainers = PortainerStore.shared.containers
			let storedContainersStates = storedContainers.reduce(into: [:]) { $0[$1.id] = (name: $1.displayName ?? $1.id, state: $1.state) }

			// Refresh containers, get new state
			let newContainersTask = await PortainerStore.shared.refreshContainers()
			let newContainers = try await newContainersTask.value
			let newContainersStates = newContainers.reduce(into: [:]) { $0[$1.id] = (name: $1.displayName ?? $1.id, state: $1.state) }

			// Find differences
			let differences: [AppRefreshContainerChange] = storedContainersStates
				.compactMap { id, oldState in
					guard let newState = newContainersStates[id] else { return .disappeared(name: oldState.name) }
					if newState.state != oldState.state {
						return .stateChanged(name: oldState.name, from: oldState.state, to: newState.state)
					} else {
						return nil
					}
				}

			#if DEBUG
			let debugNotification = UNMutableNotificationContent()
			debugNotification.title = "🚧 Background refresh happened!"
			debugNotification.body = differences.description
			let debugNotificationIdentifier = "Debug.BackgroundRefreshHappened"
			let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: nil)
			try? await UNUserNotificationCenter.current().add(debugNotificationRequest)
			#endif

			// Handle differences
			if differences.isEmpty {
				logger.info("Differences are empty. [\(String.debugInfo(), privacy: .public)]")
				return
			}

			logger.info("Differences count: \(differences.count, privacy: .public). [\(String.debugInfo(), privacy: .public)]")

			if let notificationContent = notificationContent(for: differences) {
				let notificationIdentifier = "\(Self.containersChangedNotificationIdentifier).\(differences.description.hashValue)"
				let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)
				try await UNUserNotificationCenter.current().add(notificationRequest)
			} else {
				logger.warning("notificationContent(for:) didn't return anything! [\(String.debugInfo(), privacy: .public)]")
			}

			logger.debug("Finished handling background refresh :) [\(String.debugInfo(), privacy: .public)]")
		} catch {
			logger.error("Error handling background refresh: \(String(describing: error), privacy: .public) [\(String.debugInfo(), privacy: .public)]")
		}
	}

	private nonisolated func notificationContent(for changes: [AppRefreshContainerChange]) -> UNNotificationContent? {
		typealias Localization = Localizable.Notifications.ContainersChanged

		let notificationContent = UNMutableNotificationContent()
		notificationContent.categoryIdentifier = Self.containersChangedNotificationIdentifier
		notificationContent.interruptionLevel = .active
		notificationContent.relevanceScore = Double(changes.count) / 10
		notificationContent.sound = .default
		notificationContent.userInfo = [
			"changes": changes
		]

		let emoji: String
		let title: String = Localization.title
		let subtitle: String

		switch changes.count {
			case 1:
				// One difference, use singular notification content
				guard let change = changes.first else { return nil }
				switch change {
					case .disappeared(let name):
						// "😶‍🌫️ Container "<name>" disappeared"
						emoji = "😶‍🌫️"
						subtitle = Localization.Subtitle.containerDisappeared(name)
					case .stateChanged(let name, _, let to):
						// "<emoji> Container "<name>" changed its state to <to>."
						switch to {
							case .dead:
								emoji = "☠️"
							case .created:
								emoji = "🐣" // 👶
							case .exited:
								emoji = "🚪"
							case .paused:
								emoji = "⏸️"
							case .removing:
								emoji = "🗑️"
							case .restarting:
								emoji = "🔄"
							case .running:
								emoji = "🏃"
							case .none:
								emoji = "❔"
						}
						let stateOrUnknown = to?.rawValue ?? Localization.unknownPlaceholder
						subtitle = Localization.Subtitle.containerChangedState(name, stateOrUnknown)
				}
			case 2...3:
				// Multiple differences, readable, use plural notification content
				// "Containers "<container1>", "<container2>" and "<container3>" changed their states"
				let names = changes.map {
					switch $0 {
						case .stateChanged(let name, _, _):
							return "\"\(name)\""
						case .disappeared(let name):
							return "\"\(name)\""
					}
				}
				let namesJoined = names.formatted(.list(type: .and))
				emoji = "📫" // 🗂️ 👯
				subtitle = Localization.Subtitle.ContainersChangedStates.readable(namesJoined)
			case 4...:
				// Multiple differences, unreadable, use "multiple changes" notification content
				// "Multiple containers changed their states"
				emoji = "📫" // 🗂️ 👯
				subtitle = Localization.Subtitle.ContainersChangedStates.unreadable
			default:
				// What
				return nil
		}

		notificationContent.title = "\(emoji) \(title)"
		notificationContent.subtitle = subtitle

		return notificationContent
	}

}
