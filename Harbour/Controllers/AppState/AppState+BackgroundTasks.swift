//
//  AppState+BackgroundTasks.swift
//  Harbour
//
//  Created by royal on 01/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import BackgroundTasks
import CommonFoundation
import Foundation
import PortainerKit
import UserNotifications

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
			logger.error("Error scheduling background task with identifier: \"\(request.identifier, privacy: .public)\": \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		}
	}
}

// MARK: - AppState+Common

private extension AppState {
	struct AppRefreshContainerChange: Hashable, Codable {
		enum ChangeType: Int, Hashable, Codable {
			case removed = -1
			case changed = 0
			case inserted = 1
		}

		static let dictionaryKey = "changes"

		let id: Container.ID
		let name: String?
		let oldState: ContainerState?
		let newState: ContainerState?
		let status: String?
		let image: String?
		let associationID: String?
		let changeType: ChangeType

		func isSame(as other: Self) -> Bool {
			self.id == other.id || (self.associationID != nil && self.associationID == other.associationID) || (self.image == other.image && self.name == other.name)
		}
	}
}

// MARK: - AppState+BackgroundRefresh

extension AppState {
	/// Handles the background refresh task.
	@Sendable
	nonisolated func handleBackgroundRefresh() async {
		do {
			loggerBackground.notice("Handling background refresh... [\(String._debugInfo(), privacy: .public)]")

			#if DEBUG
			Task { @MainActor in
				Preferences.shared.lastBackgroundRefreshDate = Date().timeIntervalSince1970
			}
			#endif

			scheduleBackgroundRefresh()

			let portainerStore = PortainerStore(urlSessionConfiguration: .intents)
			await portainerStore.setupTask?.value
			await portainerStore.loadStoredContainersIfNeeded()

			let oldContainers = portainerStore.containers
				.map { Container(id: $0.id, names: $0.names, image: $0.image, labels: $0.labels, state: $0.state, status: $0.status) }

			let newContainersTask = portainerStore.refreshContainers()
			let newContainers = try await newContainersTask.value
				.map { Container(id: $0.id, names: $0.names, image: $0.image, labels: $0.labels, state: $0.state, status: $0.status) }

			try await handleContainersUpdate(from: oldContainers, to: newContainers)
		} catch {
			loggerBackground.error("Error handling background refresh: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
		}
	}

	/// Handles the containers change, providing a notificaion if needed.
	/// - Parameters:
	///   - oldContainers: Old (pre-update) containers.
	///   - newContainers: New (post-update) containers.
	@Sendable
	nonisolated func handleContainersUpdate(from oldContainers: [Container], to newContainers: [Container]) async throws {
		let differences: [AppRefreshContainerChange] = newContainers
			.difference(from: oldContainers) { $0.isSame(as: $1) }
			.inferringMoves()
			.map {
				switch $0 {
				case .insert(_, let container, _):
					return .init(
						id: container.id,
						name: "D:I:" + (container.displayName ?? ""),
						oldState: nil,
						newState: container.state,
						status: container.status,
						image: container.image,
						associationID: container.associationID,
						changeType: .inserted
					)
				case .remove(_, let container, _):
					let oldContainer = oldContainers.first(where: { $0.id == container.id })
					return .init(
						id: container.id,
						name: "D:R:" + (container.displayName ?? ""),
						oldState: oldContainer?.state,
						newState: nil,
						status: nil,
						image: container.image,
						associationID: container.associationID,
						changeType: .removed
					)
				}
			}

//		let changesOld: [AppRefreshContainerChange] = oldContainers
//			.map { oldContainer in
//				let newContainer = newContainers.first(where: { $0.isSame(as: oldContainer) })
//				return .init(
//					id: oldContainer.id,
//					name: "O:" + (oldContainer.displayName ?? ""),
//					oldState: oldContainer.state,
//					newState: newContainer?.state,
//					status: newContainer?.status,
//					image: newContainer?.image ?? oldContainer.image,
//					associationID: newContainer?.associationID ?? oldContainer.associationID,
//					changeType: newContainer != nil ? .changed : .removed
//				)
//			}
//
//		let changesNew: [AppRefreshContainerChange] = newContainers
//			.compactMap { newContainer in
//				let oldContainer = oldContainers.first(where: { $0.isSame(as: newContainer) })
//				return .init(
//					id: newContainer.id,
//					name: "N:" + (newContainer.displayName ?? ""),
//					oldState: oldContainer?.state,
//					newState: newContainer.state,
//					status: newContainer.status,
//					image: newContainer.image,
//					associationID: newContainer.associationID ?? oldContainer?.associationID,
//					changeType: oldContainer != nil ? .changed : .removed
//				)
//			}

//		let changesAndDifferences: [AppRefreshContainerChange] = (changes + differences)
//			.filter { $0.oldState != $0.newState }
//			.sorted { $0.changeType.rawValue > $1.changeType.rawValue } // Place `removed` at the end
//			.reduce(into: []) { result, change in
//				if change.changeType == .removed {
//					if !result.contains(where: { $0.isSame(as: change) }) {
//						result.append(change)
//					}
//				} else {
//					result.append(change)
//				}
//			}
//			.sorted { ($0.name ?? "", $0.id) < ($1.name ?? "", $1.id) }

//		let differencesSorted = (changesOld + changesNew)
//			.filter { $0.oldState != $0.newState }
//			.sorted { ($0.name ?? "", $0.id) < ($1.name ?? "", $1.id) }

		let differencesSorted: [AppRefreshContainerChange] = differences
			.filter { $0.oldState != $0.newState }
			.sorted { ($0.changeType.rawValue, $0.name ?? "") > ($1.changeType.rawValue, $1.name ?? "") } // Place `removed` at the end
//			.reduce(into: []) { result, change in
//				if change.changeType == .removed && result.contains(where: { $0.isSame(as: change) }) {
//					return
//				}
//
//				result.append(change)
//			}
//			.sorted { ($0.name ?? "", $0.id) < ($1.name ?? "", $1.id) }

		loggerBackground.notice("Differences: \(differencesSorted, privacy: .public) [\(String._debugInfo(), privacy: .public)]")

		if differencesSorted.isEmpty {
			return
		}

		if let notificationContent = notificationContent(for: differencesSorted) {
			let notificationIdentifier = "\(HarbourNotificationIdentifier.containersChanged).\(differencesSorted.description.hashValue)"
			let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)
			try await UNUserNotificationCenter.current().add(notificationRequest)
		} else {
			loggerBackground.warning("notificationContent(for:) didn't return anything! [\(String._debugInfo(), privacy: .public)]")
		}
	}

	/// Generates the notificaion content for provided container changes.
	/// - Parameter changes: Container changes between the refreshes.
	/// - Returns: `UNNotificationContent` for the container change notification.
	private nonisolated func notificationContent(for changes: [AppRefreshContainerChange]) -> UNNotificationContent? {
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
					title = String(localized: "Notification.ContainersChanged.Single.Inserted.Title Name:\(change.name ?? change.id)")
					body = String(localized: "Notification.ContainersChanged.Single.Inserted.Body Status:\(change.status ?? newStateReadable)")
				} else {
					title = String(localized: "Notification.ContainersChanged.Single.Changed.Title Name:\(change.name ?? change.id)")
					body = String(localized: "Notification.ContainersChanged.Single.Changed.Body Old:\(oldStateReadable) New:\(change.status ?? newStateReadable)")
				}
			case .removed:
				emoji = String(localized: "Notification.ContainersChanged.Single.Removed.Emoji")
				title = String(localized: "Notification.ContainersChanged.Single.Removed.Title Name:\(change.name ?? change.id)")
				body = String(localized: "Notification.ContainersChanged.Single.Removed.Body Change:\(change.oldState.description.localizedCapitalized)")
			}
//		case 2...4:
		case 2...:
			let namesJoined = changes
				.map { $0.name ?? $0.id }
				.formatted(.list(type: .and))

			let changesJoined = changes
				.map { "\($0.name ?? $0.id): \($0.status ?? $0.newState.description.localizedCapitalized)" }
				.joined(separator: "\n")

			emoji = String(localized: "Notification.ContainersChanged.MultipleReadable.Emoji")
			title = String(localized: "Notification.ContainersChanged.MultipleReadable.Title Names:\(namesJoined)")
			body = changesJoined
//		case 5...:
//			emoji = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Emoji")
//			title = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Title ChangeCount:\(changes.count)")
//			body = changes
//				.map { $0.name ?? $0.id }
//				.formatted(.list(type: .and))
		default:
			return nil
		}

		notificationContent.title = "\(emoji) \(title)"
		notificationContent.body = body

		return notificationContent
	}
}
