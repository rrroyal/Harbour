//
//  NotificationHelper+ContainersChanged.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit
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
		notificationContent.userInfo = [
			UserInfoKey.containerChanges: (try? encodeNotificationPayload(containerChanges)) as Any
		]

		let emoji: String
		let title: String
		let body: String

		switch containerChanges.count {
		case 1:
			guard let change = containerChanges.first else { return nil }

			emoji = change.changeEmoji

			let containerName = "\"\(change.containerName)\""

			switch change.changeType {
			case .created:
				title = String(localized: "Notification.ContainersChanged.Single.Created.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Created.Body Status:\(change.changeDescription)")
			case .changed:
				title = String(localized: "Notification.ContainersChanged.Single.Changed.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Changed.Body Old:\((change.old?.state ?? Container.State?.none).title) New:\(change.changeDescription)")
			case .recreated:
				title = String(localized: "Notification.ContainersChanged.Single.Recreated.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Recreated.Body New:\(change.changeDescription)")
			case .removed:
				title = String(localized: "Notification.ContainersChanged.Single.Removed.Title Name:\(containerName)")
				body = String(localized: "Notification.ContainersChanged.Single.Removed.Body Old:\((change.old?.state ?? Container.State?.none).title)")
			}
		case 2...:
			emoji = "📫"

			let namesJoined = containerChanges
				.map { "\"\($0.containerName)\"" }
				.formatted(.list(type: .and))
			title = String(localized: "Notification.ContainersChanged.MultipleReadable.Title Names:\(namesJoined)")

			let changesJoined = containerChanges
				.map { change in
					let parts = [
						change.containerName,
						": ",
						change.changeType == .recreated ? "\(String(localized: "Generic.Recreated")), " : "",
						change.changeType != .removed ? change.changeDescription : String(localized: "Generic.Removed")
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

		return notificationContent
	}
}
