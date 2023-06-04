//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Combine
import OSLog
import SwiftUI
import NotificationCenter
import BackgroundTasks
import CommonFoundation
import CommonOSLog

// MARK: - Preferences

/// UserDefaults wrapper; user preferences store.
public final class Preferences: ObservableObject {
	public static let shared = Preferences()
	// swiftlint:disable:next force_unwrapping
	public static let userDefaults: UserDefaults = .group!

	private let logger = Logger(category: Logger.Category.preferences)

	/// Was landing view displayed?
	@AppStorage(Keys.landingDisplayed, store: Preferences.userDefaults) public var landingDisplayed = false

	/// Are haptics enabled?
	@AppStorage(Keys.enableHaptics, store: Preferences.userDefaults) public var enableHaptics = true

	/// Is background refresh enabled?
	@AppStorage(Keys.enableBackgroundRefresh, store: Preferences.userDefaults) public var enableBackgroundRefresh = false {
		didSet { onEnableBackgroundRefreshChange(enableBackgroundRefresh) }
	}

	#if DEBUG
	/// Last background refresh time.
	@AppStorage(Keys.lastBackgroundRefreshDate, store: Preferences.userDefaults) public var lastBackgroundRefreshDate: TimeInterval?
	#endif

	/// Selected server.
	@AppStorage(Keys.selectedServer, store: Preferences.userDefaults) public var selectedServer: String?

	/// Selected endpoint.
	@AppStorage(Keys.selectedEndpoint, store: Preferences.userDefaults) public var selectedEndpoint: StoredEndpoint?

	/// Display summary in ContainersView.
	@AppStorage(Keys.cvDisplaySummary, store: Preferences.userDefaults) public var cvDisplaySummary = false

	/// Use two-columns layout.
	@AppStorage(Keys.cvUseColumns, store: Preferences.userDefaults) public var cvUseColumns = true

	/// Display ContainersView as grid.
	@AppStorage(Keys.cvUseGrid, store: Preferences.userDefaults) public var cvUseGrid = true

	private init() {}
}

// MARK: - Preferences+Handlers

private extension Preferences {
	func onEnableBackgroundRefreshChange(_ isEnabled: Bool) {
		logger.debug("\(Keys.enableBackgroundRefresh, privacy: .public): \(isEnabled, privacy: .public) [\(String._debugInfo(), privacy: .public)]")

		let notificationCenter = UNUserNotificationCenter.current()

		if isEnabled {
			// Ask for permission
			notificationCenter.requestAuthorization(options: [.alert, .sound, .providesAppNotificationSettings]) { [weak self] allowed, error in
				guard let self else { return }
				if let error {
					self.logger.error("Error requesting notifications authorization: \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
				}
				self.logger.debug("Notifications authorization allowed: \(allowed, privacy: .public) [\(String._debugInfo(), privacy: .public)]")

				if error != nil || !allowed {
					DispatchQueue.main.async {
						self.enableBackgroundRefresh = false
					}
				}
			}
		} else {
			// Remove background refreshes and pending notifications
			BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: HarbourBackgroundTaskIdentifier.backgroundRefresh)
			notificationCenter.removePendingNotificationRequests(withIdentifiers: [HarbourNotificationIdentifier.containersChanged])
		}
	}
}
