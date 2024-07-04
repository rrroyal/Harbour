//
//  NotificationHelper+ContainersChanged.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import UserNotifications

extension NotificationHelper {
	/// Generates the notificaion content for provided container changes.
	/// - Parameter containerChanges: Container changes to provide notification content for
	/// - Returns: `UNNotificationContent` for the container change notification
	static func notificationContent(for containerChanges: [ContainerChange]) -> UNNotificationContent? {
		let notificationContent = UNMutableNotificationContent()
		notificationContent.categoryIdentifier = NotificationIdentifier.containersChanged
		notificationContent.threadIdentifier = NotificationIdentifier.containersChanged
		notificationContent.interruptionLevel = .active
		notificationContent.relevanceScore = Double(containerChanges.count) / 10
		notificationContent.sound = .default
//		notificationContent.userInfo = [
//			UserInfoKey.endpointID: containerChanges.first?.endpointID as Any,
//			UserInfoKey.changedIDs: containerChanges.map { $0.newID ?? $0.oldID }
//		]

		let emoji: String
		let title: String
		let body: String

		switch containerChanges.count {
		case 1:
			guard let change = containerChanges.first else { return nil }

			emoji = change.changeEmoji

			let status: String = if let newStatus = change.newStatus {
				"\(newStatus) (\(change.newState.title))"
			} else {
				change.newState.title
			}
			let containerName = "\"\(change.containerName)\""

			switch change.changeType {
			case .created:
				title = String(localized: "Notification.ContainersChanged.Single.Created.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Created.Body Status:\(status)")
			case .changed:
				title = String(localized: "Notification.ContainersChanged.Single.Changed.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Changed.Body Old:\(change.oldState.title) New:\(status)")
			case .recreated:
				title = String(localized: "Notification.ContainersChanged.Single.Recreated.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Recreated.Body New:\(status)")
			case .removed:
				title = String(localized: "Notification.ContainersChanged.Single.Removed.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Removed.Body Old:\(change.oldState.title)")
			}
		case 2...:
			emoji = "📫"

			let namesJoined = containerChanges
				.map { "\"\($0.containerName)\"" }
				.formatted(.list(type: .and))
			title = String(localized: "Notification.ContainersChanged.MultipleReadable.Title Names:\(namesJoined)")

			let changesJoined = containerChanges
				.map {
					let status: String = if let newStatus = $0.newStatus {
						"\(newStatus) (\($0.newState.title))"
					} else {
						$0.newState.title
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
			emoji = "📫"

			title = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Title ChangeCount:\(containerChanges.count)")

			let changesJoined = containerChanges
				.map { "\"\($0.containerName)\"" }
				.formatted(.list(type: .and))
			body = String(localized: "Notification.ContainersChanged.MultipleUnreadable.Body Changes:\(changesJoined)")
		default:
			return nil
		}

		notificationContent.title = "\(emoji) \(title)"
		notificationContent.body = body
		notificationContent.userInfo[UserInfoKey.containerChanges] = try? NotificationHelper.encodeNotificationPayload(containerChanges)

		return notificationContent
	}
}
