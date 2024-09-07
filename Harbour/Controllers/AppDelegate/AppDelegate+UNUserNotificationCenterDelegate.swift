//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
	nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		[.banner, .list, .sound]
	}

	nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		await AppState.shared.handleNotification(response)
	}
}
