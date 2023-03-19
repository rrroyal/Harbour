//
//  AppState+BackgroundTasks.swift
//  Harbour
//
//  Created by royal on 01/10/2022.
//

import Foundation
import BackgroundTasks
import UserNotifications
import WidgetKit
import PortainerKit
import CommonFoundation

// MARK: - AppState+scheduleBackgroundRefresh

extension AppState {

	func scheduleBackgroundRefresh() {
		guard Preferences.shared.enableBackgroundRefresh else {
			logger.info("\(Preferences.Keys.enableBackgroundRefresh, privacy: .public) disabled [\(String._debugInfo(), privacy: .public)]")
			return
		}

		let identifier = HarbourBackgroundTaskIdentifier.backgroundRefresh

		logger.notice("Scheduling background refresh with identifier: \"\(identifier, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")

		let request = BGAppRefreshTaskRequest(identifier: identifier)
		request.earliestBeginDate = .now

//		#if DEBUG
//		Task {
//			let debugNotification = UNMutableNotificationContent()
//			debugNotification.title = "🚧 Background refresh scheduled (oh my god it will happen)"
//			debugNotification.threadIdentifier = "debug"
//			let debugNotificationIdentifier = "Debug.BackgroundRefreshScheduled"
//			let debugNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//			let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: debugNotificationTrigger)
//			try? await UNUserNotificationCenter.current().add(debugNotificationRequest)
//		}
//		#endif

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			// swiftlint:disable:next line_length
			logger.error("Error scheduling background task with identifier: \"\(request.identifier, privacy: .public)\": \(error.localizedDescription, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		}
	}

}

// MARK: - AppState+handleBackgroundRefresh

extension AppState {

//	private enum AppRefreshContainerChange {
//		case disappeared(name: String, lastKnownState: ContainerState?)
//		case stateChanged(name: String, from: ContainerState?, to: ContainerState?)
//	}

	private struct AppRefreshContainerChange: Hashable, Codable {
		enum ChangeType: Int, Hashable, Codable {
			case inserted = 0
			case removed
			case changed
		}

		static let dictionaryKey = "changes"

		let id: Container.ID
		let name: String
		let oldState: ContainerState?
		let newState: ContainerState?
		let status: String?
		let changeType: ChangeType
	}

	private static let logPrefix = "BackgroundRefresh"

	@Sendable
	// swiftlint:disable:next function_body_length
	nonisolated func handleBackgroundRefresh() async {
		do {
			logger.notice("[\(Self.logPrefix, privacy: .public)] Handling background refresh... [\(String._debugInfo(), privacy: .public)]")

			#if DEBUG
			Preferences.shared.lastBackgroundRefreshDate = Date().timeIntervalSince1970
			#endif

//			#if DEBUG
//			Task {
//				let debugNotification = UNMutableNotificationContent()
//				debugNotification.title = "🚧 Background refresh (oh my god its happening)"
//				debugNotification.threadIdentifier = "debug"
//				let debugNotificationIdentifier = "Debug.BackgroundRefreshHappening"
//				let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: nil)
//				try? await UNUserNotificationCenter.current().add(debugNotificationRequest)
//			}
//			#endif

			// Schedule new background refresh
			scheduleBackgroundRefresh()

			// Reload widget timelines
			WidgetCenter.shared.reloadAllTimelines()

			let portainerStore = PortainerStore(urlSessionConfiguration: .intents)
			await portainerStore.setupTask?.value

			/*
			// Get pre-refresh containers
			let storedContainers = portainerStore.containers
			let storedContainersStates = storedContainers.reduce(into: [:]) { $0[$1.id] = $1 }

			// Refresh containers and get new state
			let newContainersTask = portainerStore.refreshContainers()
			let newContainers = try await newContainersTask.value
			let newContainersStates = newContainers.reduce(into: [:]) { $0[$1.id] = $1 }

			// Find differences
			let differences: [AppRefreshContainerChange] = storedContainersStates
				.map { id, oldContainer in
					let newContainer = newContainersStates[id]
					return .init(id: id,
								 name: oldContainer.displayName ?? id,
								 oldState: oldContainer.state,
								 newState: newContainer?.state,
								 status: newContainer?.status)
				}
				.filter { $0.oldState != $0.newState }
				.sorted { $0.id < $1.id }
			 */

			let oldContainers = portainerStore.containers
				.map { Container(id: $0.id, names: $0.names, state: $0.state, status: $0.status) }

			// Refresh containers and get new state
			let newContainersTask = portainerStore.refreshContainers()
			let newContainers = try await newContainersTask.value
				.map { Container(id: $0.id, names: $0.names, state: $0.state, status: $0.status) }

			let differences: [AppRefreshContainerChange] = newContainers
				.sorted { $0.id < $1.id }
				.difference(from: oldContainers) { $0.state == $1.state }
				.map {
					switch $0 {
						case .insert(_, let container, _):
							return .init(id: container.id,
										 name: container.displayName ?? container.id,
										 oldState: nil,
										 newState: container.state,
										 status: container.status,
										 changeType: .inserted)
						case .remove(_, let container, _):
							let oldContainer = oldContainers.first(where: { $0.id == container.id })
							return .init(id: container.id,
										 name: container.displayName ?? container.id,
										 oldState: oldContainer?.state,
										 newState: nil,
										 status: nil,
										 changeType: .removed)
					}
				}

			let changes: [AppRefreshContainerChange] = oldContainers
				.map { oldContainer in
					let newContainer = newContainers.first(where: { $0.id == oldContainer.id })
					return .init(id: oldContainer.id,
								 name: oldContainer.displayName ?? oldContainer.id,
								 oldState: oldContainer.state,
								 newState: newContainer?.state,
								 status: newContainer?.status,
								 changeType: newContainer != nil ? .changed : .removed)
				}

			let changesAndDifferences = (changes /* + differences */)
				.filter { $0.oldState != $0.newState }
				.sorted { $0.id < $1.id }

			#if DEBUG
			Task {
				let debugNotification = UNMutableNotificationContent()
				debugNotification.title = "🚧 Background refresh (oh my god its happening)"
				debugNotification.body = String(describing: changesAndDifferences)
				debugNotification.threadIdentifier = "debug"
				let debugNotificationIdentifier = "Debug.BackgroundRefreshHappening"
				let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: nil)
				try? await UNUserNotificationCenter.current().add(debugNotificationRequest)
			}
			#endif

			// Handle differences
			if changesAndDifferences.isEmpty {
				logger.debug("[\(Self.logPrefix, privacy: .public)] Differences are empty [\(String._debugInfo(), privacy: .public)]")
				return
			}

			logger.debug("[\(Self.logPrefix, privacy: .public)] Differences count: \(changesAndDifferences.count, privacy: .public) [\(String._debugInfo(), privacy: .public)]")

			if let notificationContent = notificationContent(for: changesAndDifferences) {
				let notificationIdentifier = "\(HarbourNotificationIdentifier.containersChanged).\(changesAndDifferences.description.hashValue)"
				let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)
				try await UNUserNotificationCenter.current().add(notificationRequest)
			} else {
				logger.warning("[\(Self.logPrefix, privacy: .public)] notificationContent(for:) didn't return anything! [\(String._debugInfo(), privacy: .public)]")
			}

			logger.info("[\(Self.logPrefix, privacy: .public)] Finished handling background refresh :) [\(String._debugInfo(), privacy: .public)]")
		} catch {
			// swiftlint:disable:next line_length
			logger.error("[\(Self.logPrefix, privacy: .public)] Error handling background refresh: \(error.localizedDescription, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		}
	}

	private nonisolated func notificationContent(for changes: [AppRefreshContainerChange]) -> UNNotificationContent? {
		typealias Localization = Localizable.Notifications.ContainersChanged

		let notificationContent = UNMutableNotificationContent()
		notificationContent.threadIdentifier = HarbourNotificationIdentifier.containersChanged
		notificationContent.interruptionLevel = .active
		notificationContent.relevanceScore = Double(changes.count) / 10
		notificationContent.sound = .default
//		notificationContent.userInfo = [
//			AppRefreshContainerChange.dictionaryKey: changes
//		]

		let emoji: String
		let title: String
		let body: String

		switch changes.count {
			case 1:
				guard let change = changes.first else { return nil }

				switch change.changeType {
					case .inserted, .changed:
						emoji = change.newState.emoji

						let oldStateReadable = change.oldState.description.localizedCapitalized
						let newStateReadable = change.newState.description.localizedCapitalized

						if change.changeType == .inserted {
							title = Localization.Single.Inserted.title(change.name)
							body = Localization.Single.Inserted.body(change.status ?? newStateReadable)
						} else {
							title = Localization.Single.Changed.title(change.name)
							body = Localization.Single.Changed.body(oldStateReadable, change.status ?? newStateReadable)
						}
					case .removed:
						emoji = Localization.Single.Removed.emoji
						title = Localization.Single.Removed.title(change.name)
						body = Localization.Single.Removed.body(change.oldState.description.localizedCapitalized)
				}
			case 2...4:
				let namesJoined = changes
					.map(\.name)
					.formatted(.list(type: .and))

				let changesJoined = changes
					.map { "\($0.name): \($0.status ?? $0.newState.description.localizedCapitalized)" }
					.joined(separator: "\n")

				emoji = Localization.MultipleReadable.emoji
				title = Localization.MultipleReadable.title(namesJoined)
				body = changesJoined
			case 5...:
				emoji = Localization.MultipleUnreadable.emoji
				title = Localization.MultipleUnreadable.title(changes.count)
				body = changes.map(\.name).formatted(.list(type: .and))
			default:
				return nil
		}

		notificationContent.title = "\(emoji) \(title)"
		notificationContent.body = body

		return notificationContent
	}

}
