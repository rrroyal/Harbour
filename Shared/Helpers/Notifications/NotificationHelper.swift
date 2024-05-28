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

enum NotificationHelper {
	private static let jsonEncoder = JSONEncoder()
	private static let jsonDecoder = JSONDecoder()

	static func encodeNotificationPayload<P: Encodable>(_ payload: P) throws -> Data {
		try jsonEncoder.encode(payload)
	}

	static func decodeNotificationPayload<D: Decodable>(from data: Data) throws -> D {
		try jsonDecoder.decode(D.self, from: data)
	}
}

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
		static let containerChanges = "ContainerChanges"
	}
}

// swiftlint:enable force_unwrapping
