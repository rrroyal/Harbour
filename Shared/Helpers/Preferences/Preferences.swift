//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import SwiftUI
import OSLog
import NotificationCenter
import BackgroundTasks

// MARK: - Preferences

/// UserDefaults wrapper; user preferences store.
public final class Preferences: ObservableObject {
	public static let shared = Preferences()
	public static let ud: UserDefaults = .group

	private let logger = Logger(category: .preferences)

	@AppStorage(Keys.landingDisplayed, store: .group) public var landingDisplayed = false
	@AppStorage(Keys.enableHaptics, store: .group) public var enableHaptics = true

	@AppStorage(Keys.enableBackgroundRefresh, store: .group) public var enableBackgroundRefresh = false {
		didSet { onEnableBackgroundRefreshChange(enableBackgroundRefresh) }
	}
	#if DEBUG
	@AppStorage(Keys.lastBackgroundRefreshDate, store: .group) public var lastBackgroundRefreshDate: TimeInterval?
	#endif

	@AppStorage(Keys.selectedServer, store: .group) public var selectedServer: String?
	@AppStorage(Keys.selectedEndpointID, store: .group) public var selectedEndpointID: Int?

	@AppStorage(Keys.cvUseGrid, store: .group) public var cvUseGrid = false

	private init() {}
}

// MARK: - Preferences+Handlers

private extension Preferences {
	func onEnableBackgroundRefreshChange(_ isEnabled: Bool) {
		logger.debug("\(Keys.enableBackgroundRefresh, privacy: .public): \(isEnabled, privacy: .public) [\(String.debugInfo(), privacy: .public)]")

		let notificationCenter = UNUserNotificationCenter.current()

		if isEnabled {
			// Ask for permission
			notificationCenter.requestAuthorization(options: [.alert, .sound, .providesAppNotificationSettings]) { [weak self] allowed, error in
				guard let self else { return }
				if let error {
					self.logger.error("Error requesting notifications authorization: \(error, privacy: .public) [\(String.debugInfo(), privacy: .public)]")
				}
				self.logger.debug("Notifications authorization allowed: \(allowed, privacy: .public) [\(String.debugInfo(), privacy: .public)]")

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
