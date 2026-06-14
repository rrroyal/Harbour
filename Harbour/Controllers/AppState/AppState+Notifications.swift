//
//  AppState+Notifications.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

@preconcurrency import UserNotifications

extension AppState {
	func handleNotification(_ notification: UNNotificationResponse) {
		notificationsToHandle.insert(notification)
	}

	func notificationHandled(_ notification: UNNotificationResponse) {
		notificationsToHandle.remove(notification)
	}
}
