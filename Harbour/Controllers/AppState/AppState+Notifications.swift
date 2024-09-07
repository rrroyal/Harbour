//
//  AppState+Notifications.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

@preconcurrency import UserNotifications

extension AppState {
	nonisolated func handleNotification(_ notification: UNNotificationResponse) {
		Task { @MainActor in
			notificationsToHandle.insert(notification)
		}
	}

	nonisolated func notificationHandled(_ notification: UNNotificationResponse) {
		Task { @MainActor in
			notificationsToHandle.remove(notification)
		}
	}
}
