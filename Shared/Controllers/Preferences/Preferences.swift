//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import BackgroundTasks
import Combine
import CommonFoundation
import CommonOSLog
import NotificationCenter
import OSLog
import SwiftUI

// MARK: - Preferences

/// UserDefaults wrapper; user preferences store.
public final class Preferences: ObservableObject, @unchecked Sendable {

	public static let shared = Preferences()
	// swiftlint:disable:next force_unwrapping
	public static let userDefaults: UserDefaults = .group!

	private let logger = Logger(.custom(Preferences.self))

	/// Was landing view displayed?
	@AppStorage(Key.landingDisplayed, store: Preferences.userDefaults) public var landingDisplayed = false

	/// Are haptics enabled?
	@AppStorage(Key.enableHaptics, store: Preferences.userDefaults) public var enableHaptics = true

	/// Is background refresh enabled?
	#if os(iOS)
	@AppStorage(Key.enableBackgroundRefresh, store: Preferences.userDefaults) public var enableBackgroundRefresh = false {
		didSet { onEnableBackgroundRefreshChange(enableBackgroundRefresh) }
	}
	#endif

	/// Last background refresh time
	@AppStorage(Key.lastBackgroundRefreshDate, store: Preferences.userDefaults) public var lastBackgroundRefreshDate: TimeInterval?

	/// Selected server
	@AppStorage(Key.selectedServer, store: Preferences.userDefaults) public var selectedServer: String?

	/// Selected endpoint
	@AppStorage(Key.selectedEndpoint, store: Preferences.userDefaults) public var selectedEndpoint: StoredEndpoint?

	// Display summary in ContainersView
//	@AppStorage(Key.cvDisplaySummary, store: Preferences.userDefaults) public var cvDisplaySummary = false

	/// Use two-columns layout
	@AppStorage(Key.cvUseColumns, store: Preferences.userDefaults) public var cvUseColumns = false

	/// Display ContainersView as grid
	@AppStorage(Key.cvUseGrid, store: Preferences.userDefaults) public var cvUseGrid = true

	private init() { }
}

// MARK: - Preferences+Handlers

private extension Preferences {
	#if os(iOS)
	func onEnableBackgroundRefreshChange(_ isEnabled: Bool) {
		logger.debug("\(Key.enableBackgroundRefresh, privacy: .public): \(isEnabled, privacy: .public)")

		let notificationCenter = UNUserNotificationCenter.current()

		if isEnabled {
			// Ask for permission
			Task {
				do {
					let allowed = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .providesAppNotificationSettings])
					logger.debug("Notifications authorization allowed: \(allowed, privacy: .public)")

					if !allowed {
						await MainActor.run {
							self.enableBackgroundRefresh = false
						}
					}
				} catch {
					self.logger.error("Error requesting notifications authorization: \(error, privacy: .public)")
					await MainActor.run {
						self.enableBackgroundRefresh = false
					}
				}
			}
		} else {
			// Remove background refreshes and pending notifications
			BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundHelper.TaskIdentifier.backgroundRefresh)
			notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationHelper.NotificationIdentifier.containersChanged])
		}
	}
	#endif
}
