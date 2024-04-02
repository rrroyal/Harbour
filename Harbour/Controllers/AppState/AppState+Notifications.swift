//
//  AppState+Notifications.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import UserNotifications

extension AppState {
	@MainActor
	func handleNotification(_ notification: UNNotificationResponse) {
		notificationsToHandle.insert(notification)
	}

	@MainActor
	func notificationHandled(_ notification: UNNotificationResponse) {
		notificationsToHandle.remove(notification)
	}
}
