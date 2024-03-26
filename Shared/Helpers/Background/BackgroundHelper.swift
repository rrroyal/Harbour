//
//  BackgroundHelper.swift
//  Harbour
//
//  Created by royal on 03/02/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import BackgroundTasks
import CommonFoundation
import CommonOSLog
import Foundation
import OSLog
import PortainerKit
import SwiftData
import UserNotifications

// MARK: - BackgroundHelper

/// Helper for background-related tasks.
struct BackgroundHelper: Sendable {
	internal static let logger = Logger(.custom(BackgroundHelper.self))
	internal static let loggerBackground = Logger(.background)
}

// MARK: - BackgroundHelper+BackgroundRefresh

extension BackgroundHelper {
	#if os(iOS)
	/// Schedules a new background refresh task.
	@Sendable
	static func scheduleBackgroundRefreshIfNeeded() {
		guard Preferences.shared.enableBackgroundRefresh else {
			logger.debug("\(Preferences.Key.enableBackgroundRefresh, privacy: .public) disabled")
			return
		}

		let identifier = TaskIdentifier.backgroundRefresh

		logger.notice("Scheduling background refresh with identifier: \"\(identifier, privacy: .public)\"")

		let request = BGAppRefreshTaskRequest(identifier: identifier)
		request.earliestBeginDate = .now

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			logger.error("Error scheduling background task with identifier: \"\(request.identifier, privacy: .public)\": \(error, privacy: .public)")
		}
	}
	#endif

	#if TARGET_APP
	/// Handles the background refresh task.
	@Sendable
	static func handleBackgroundRefresh() async {
		do {
			loggerBackground.notice("Handling background refresh...")

			#if DEBUG
			Task { @MainActor in
				Preferences.shared.lastBackgroundRefreshDate = Date().timeIntervalSince1970
			}
			#endif

			#if os(iOS)
			scheduleBackgroundRefreshIfNeeded()
			#endif

			let modelContainer = try ModelContainer(for: StoredContainer.self)
			let modelContext = ModelContext(modelContainer)
//			let modelContext = await modelContainer.mainContext

			let portainerStore = PortainerStore(modelContext: modelContext, urlSessionConfiguration: .backgroundTasks)
			if !portainerStore.isSetup {
				await portainerStore.setupInitially()
			}

			let oldContainers = portainerStore.containers
//				.map { Container(id: $0.id, names: $0.names, image: $0.image, labels: $0.labels, state: $0.state, status: $0.status) }

			let newContainersTask = portainerStore.refreshContainers()
			let newContainers = try await newContainersTask.value
//				.map { Container(id: $0.id, names: $0.names, image: $0.image, labels: $0.labels, state: $0.state, status: $0.status) }

			try await handleContainersUpdate(from: oldContainers, to: newContainers)
		} catch {
			loggerBackground.error("Error handling background refresh: \(error, privacy: .public)")
		}
	}
	#endif

	/// Handles the containers change, providing a notificaion if needed.
	/// - Parameters:
	///   - oldContainers: Old (pre-update) containers
	///   - newContainers: New (post-update) containers
	@Sendable
	static func handleContainersUpdate(from oldContainers: [Container], to newContainers: [Container]) async throws {
		let oldMapping = oldContainers.reduce(into: [:]) { $0[$1._persistentID] = $1 }
		let newMapping = newContainers.reduce(into: [:]) { $0[$1._persistentID] = $1 }

		// Find any changes from `oldMapping` to `newMapping`
		var changes: [ContainerChange] = newMapping
			.compactMap { key, newContainer in
				if let oldContainer = oldMapping[key] {
					// Had old container, check if it was changed or re-created
					let changeType: ContainerChange.ChangeType? = if oldContainer.id != newContainer.id {
						.recreated
					} else if oldContainer.state != newContainer.state {
						.changed
					} else {
						// It's the same, ignore
						nil
					}
					guard let changeType else { return nil }

					guard let change = ContainerChange(
						oldContainer: oldContainer,
						newContainer: newContainer,
						changeType: changeType
					) else {
						loggerBackground.warning("Unable to create ContainerChange!")
						return nil
					}
					return change
				} else {
					// No old container, so it must be a new one
					guard let change = ContainerChange(
						oldContainer: nil,
						newContainer: newContainer,
						changeType: .created
					) else {
						loggerBackground.warning("Unable to create ContainerChange!")
						return nil
					}
					return change
				}
			}

		// Check if there are any identifiers not present in `newMapping`
		let removedIdentifiers = Set(oldMapping.map(\.key)).subtracting(newMapping.map(\.key))
		changes += removedIdentifiers.compactMap { oldIdentifier in
			guard let oldContainer = oldMapping[oldIdentifier] else {
				return nil
			}
			guard let change = ContainerChange(oldContainer: oldContainer, newContainer: nil, changeType: .removed) else {
				loggerBackground.warning("Unable to create ContainerChange!")
				return nil
			}
			return change
		}

		changes = changes
			.filter { $0.changeType == .recreated ? $0.oldState != $0.newState : true }
			.localizedSorted(by: \.containerName)

		loggerBackground.notice("Changes: \(changes)")

		if changes.isEmpty {
			return
		}

		if let notificationContent = notificationContent(for: changes) {
			let notificationIdentifier = "\(HarbourNotificationIdentifier.containersChanged).\(changes.description.hashValue)"
			let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)
			try await UNUserNotificationCenter.current().add(notificationRequest)
		} else {
			loggerBackground.warning("notificationContent(for:) didn't return anything!")
		}
	}
}

// MARK: - BackgroundHelper+Private

private extension BackgroundHelper {
	/// Generates the notificaion content for provided container changes.
	/// - Parameter changes: Container changes to provide notification content for
	/// - Returns: `UNNotificationContent` for the container change notification
	@Sendable
	static func notificationContent(for changes: [ContainerChange]) -> UNNotificationContent? {
		let notificationContent = UNMutableNotificationContent()
		notificationContent.threadIdentifier = HarbourNotificationIdentifier.containersChanged
		notificationContent.interruptionLevel = .active
		notificationContent.relevanceScore = Double(changes.count) / 10
		notificationContent.sound = .default
//		notificationContent.userInfo = [
//			ContainerChange.dictionaryKey: changes
//		]

		// swiftlint:disable line_length
		/*
		let emoji: String
		let title: String
		let body: String

		switch changes.count {
		case 1:
			guard let change = changes.first else { return nil }

			emoji = change.newState.emoji

			switch change.changeType {
			case .created:
				title = String(localized: "Notification.ContainersChanged.Single.Created.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Created.Body Status:\(change.newStatus ?? change.newState.description.localizedCapitalized)")
			case .changed:
				title = String(localized: "Notification.ContainersChanged.Single.Changed.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Changed.Body Old:\(change.oldState.description.localizedCapitalized) New:\(change.newStatus ?? change.newState.description.localizedCapitalized)")
			case .recreated:
				title = String(localized: "Notification.ContainersChanged.Single.Recreated.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Recreated.Body New:\(change.newStatus ?? change.newState.description.localizedCapitalized)")
			case .removed:
				title = String(localized: "Notification.ContainersChanged.Single.Removed.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Removed.Body Old:\(change.oldState.description.localizedCapitalized)")
			}
		case 2...:
			emoji = String(localized: "Notification.ContainersChanged.MultipleReadable.Emoji")

			let namesJoined = changes
				.map(\.containerName)
				.formatted(.list(type: .and))
			title = String(localized: "Notification.ContainersChanged.MultipleReadable.Title Names:\(namesJoined)")

			let changesJoined = changes
				.map {
					[
						$0.containerName,
						": ",
						$0.changeType != .removed ? ($0.newStatus ?? $0.newState.description.localizedCapitalized) : String(localized: "Generic.Removed"),
						$0.changeType == .recreated ? " (\(String(localized: "Generic.Recreated").lowercased()))" : ""
					].joined()
				}
				.joined(separator: "\n")
			body = String(localized: "Notification.ContainersChanged.MultipleReadable.Body Changes:\(changesJoined)")
		case 4...:
			emoji = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Emoji")
			title = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Title ChangeCount:\(changes.count)")

			let changesJoined = changes
				.map(\.containerName)
				.formatted(.list(type: .and))
			body = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Body Changes:\(changesJoined)")
		default:
			return nil
		}

		notificationContent.title = "\(emoji) \(title)"
		notificationContent.body = body
		 */
		// swiftlint:enable line_length

		let title: String
		let body: String

		switch changes.count {
		case 1:
			guard let change = changes.first else { return nil }

			let status: String = if let newStatus = change.newStatus {
				"\(newStatus) (\(change.newState.description))"
			} else {
				change.newState.description.localizedCapitalized
			}

			switch change.changeType {
			case .created:
				title = String(localized: "Notification.ContainersChanged.Single.Created.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Created.Body Status:\(status)")
			case .changed:
				title = String(localized: "Notification.ContainersChanged.Single.Changed.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Changed.Body Old:\(change.oldState.description.localizedCapitalized) New:\(status)")
			case .recreated:
				title = String(localized: "Notification.ContainersChanged.Single.Recreated.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Recreated.Body New:\(status)")
			case .removed:
				title = String(localized: "Notification.ContainersChanged.Single.Removed.Title Name:\(change.containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Removed.Body Old:\(change.oldState.description.localizedCapitalized)")
			}
		case 2...:
			let namesJoined = changes
				.map(\.containerName)
				.formatted(.list(type: .and))
			title = String(localized: "Notification.ContainersChanged.MultipleReadable.Title Names:\(namesJoined)")

			let changesJoined = changes
				.map {
					let status: String = if let newStatus = $0.newStatus {
						"\(newStatus) (\($0.newState.description))"
					} else {
						$0.newState.description.localizedCapitalized
					}

					let parts = [
						$0.containerName,
						": ",
						$0.changeType == .recreated ? "\(String(localized: "Generic.Recreated")), " : "",
						$0.changeType != .removed ? status : String(localized: "Generic.Removed")
					]
					return parts.joined()
				}
				.joined(separator: "\n")
			body = String(localized: "Notification.ContainersChanged.MultipleReadable.Body Changes:\(changesJoined)")
		case 4...:
			title = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Title ChangeCount:\(changes.count)")

			let changesJoined = changes
				.map(\.containerName)
				.formatted(.list(type: .and))
			body = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Body Changes:\(changesJoined)")
		default:
			return nil
		}

		notificationContent.title = title
		notificationContent.body = body

		return notificationContent
	}
}
