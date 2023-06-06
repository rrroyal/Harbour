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

		logger.info("Scheduling background refresh with identifier: \"\(identifier, privacy: .public)\" [\(String._debugInfo(), privacy: .public)]")

		let request = BGAppRefreshTaskRequest(identifier: identifier)
		request.earliestBeginDate = .now

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			// swiftlint:disable:next line_length
			logger.error("Error scheduling background task with identifier: \"\(request.identifier, privacy: .public)\": \(error.localizedDescription, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		}
	}
}

// MARK: - AppState+Common

private extension AppState {
	struct AppRefreshContainerChange: Hashable, Codable {
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

	static let logPrefix = "BackgroundRefresh"
}

// MARK: - AppState+BackgroundRefresh

extension AppState {
	/// Handles the background refresh task.
	@Sendable
	nonisolated func handleBackgroundRefresh() async {
		do {
			logger.notice("[\(Self.logPrefix, privacy: .public)] Handling background refresh... [\(String._debugInfo(), privacy: .public)]")

			#if DEBUG
			Task { @MainActor in
				Preferences.shared.lastBackgroundRefreshDate = Date().timeIntervalSince1970
			}
			#endif

			scheduleBackgroundRefresh()

			let portainerStore = PortainerStore(urlSessionConfiguration: .intents)
			await portainerStore.setupTask?.value

			let oldContainers = portainerStore.containers
				.map { Container(id: $0.id, names: $0.names, state: $0.state, status: $0.status) }

			let newContainersTask = portainerStore.refreshContainers()
			let newContainers = try await newContainersTask.value
				.map { Container(id: $0.id, names: $0.names, state: $0.state, status: $0.status) }

			try await handleContainersUpdate(from: oldContainers, to: newContainers)
		} catch {
			// swiftlint:disable:next line_length
			logger.error("[\(Self.logPrefix, privacy: .public)] Error handling background refresh: \(error.localizedDescription, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		}
	}

	/// Handles the containers change, providing a notificaion if needed.
	/// - Parameters:
	///   - oldContainers: Old (pre-update) containers.
	///   - newContainers: New (post-update) containers.
	@Sendable
	nonisolated func handleContainersUpdate(from oldContainers: [Container], to newContainers: [Container]) async throws {
		let differences: [AppRefreshContainerChange] = newContainers
			.difference(from: oldContainers) { $0.id == $1.id }
			.inferringMoves()
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

		let changesAndDifferences = (changes + differences)
			.filter { $0.oldState != $0.newState }
			.sorted { $0.id < $1.id }

//		#if DEBUG
//		let noticeContent = changesAndDifferences
//			.map {
//				"\t- \($0.id) (\($0.name)) [\(String(describing: $0.changeType))]:\n" +
//				"\t\t- \($0.oldState.description) -> \($0.newState.description) (\($0.status ?? "none"))"
//			}
//			.joined(separator: "\n")
//		logger.notice("Changes:\n\(noticeContent, privacy: .public)\n")
//		#endif
//
//		#if DEBUG
//		Task {
//			let debugNotification = UNMutableNotificationContent()
//			debugNotification.title = "🚧 Background refresh (oh my god it happened)"
//			debugNotification.body = String(describing: changesAndDifferences)
//			debugNotification.threadIdentifier = "debug"
//			let debugNotificationIdentifier = "Debug.BackgroundRefreshHappening"
//			let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: nil)
//			try? await UNUserNotificationCenter.current().add(debugNotificationRequest)
//		}
//		#endif

		logger.notice("[\(Self.logPrefix, privacy: .public)] Differences: \(changesAndDifferences, privacy: .public) [\(String._debugInfo(), privacy: .public)]")

		if changesAndDifferences.isEmpty {
			return
		}

		if let notificationContent = notificationContent(for: changesAndDifferences) {
			let notificationIdentifier = "\(HarbourNotificationIdentifier.containersChanged).\(changesAndDifferences.description.hashValue)"
			let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)
			try await UNUserNotificationCenter.current().add(notificationRequest)
		} else {
			logger.warning("[\(Self.logPrefix, privacy: .public)] notificationContent(for:) didn't return anything! [\(String._debugInfo(), privacy: .public)]")
		}
	}

	/// Generates the notificaion content for provided container changes.
	/// - Parameter changes: Container changes between the refreshes.
	/// - Returns: `UNNotificationContent` for the container change notification.
	private nonisolated func notificationContent(for changes: [AppRefreshContainerChange]) -> UNNotificationContent? {
		typealias Localization = Localizable.Notification.ContainersChanged

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
