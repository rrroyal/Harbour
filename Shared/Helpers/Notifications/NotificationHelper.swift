//
//  NotificationHelper.swift
//  Harbour
//
//  Created by royal on 02/11/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import UserNotifications

// MARK: - NotificationHelper

enum NotificationHelper { }

// MARK: - NotificationHelper+NotificationIdentifier

// swiftlint:disable force_unwrapping

extension NotificationHelper {
	enum NotificationIdentifier {
		static let containersChanged = "\(Bundle.main.mainBundleIdentifier!).ContainersChanged"
	}
}

// MARK: - NotificationHelper+UserInfoKey

extension NotificationHelper {
	enum UserInfoKey {
		static let changedIDs = "\(Bundle.main.mainBundleIdentifier!).ChangedIDs"
		static let endpointID = "\(Bundle.main.mainBundleIdentifier!).EndpointID"
	}
}

// swiftlint:enable force_unwrapping
