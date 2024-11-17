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
import PortainerKit
import SwiftUI

// MARK: - Preferences

/// UserDefaults wrapper; user preferences store.
@MainActor
public final class Preferences: ObservableObject {
	public static let shared = Preferences()

	// swiftlint:disable:next force_unwrapping
	static let userDefaults = UserDefaults(suiteName: "group.\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!)")

	private let logger = Logger(.custom(Preferences.self))

	/// Was landing view displayed?
	@AppStorage("LandingDisplayed", store: Preferences.userDefaults)
	public var landingDisplayed = false

	/// Are haptics enabled?
	@AppStorage("EnableHaptics", store: Preferences.userDefaults)
	public var enableHaptics = true

	/// Is background refresh enabled?
	#if os(iOS)
	@AppStorage("EnableBackgroundRefresh", store: Preferences.userDefaults)
	public var enableBackgroundRefresh = false {
		didSet { onEnableBackgroundRefreshChange(enableBackgroundRefresh) }
	}
	#endif

	/// Last background refresh time
	@AppStorage("LastBackgroundRefreshDate", store: Preferences.userDefaults)
	public var lastBackgroundRefreshDate: TimeInterval?

	/// Selected server URL
	@AppStorage("SelectedServer", store: Preferences.userDefaults)
	public var selectedServer: String?

	/// Selected endpoint
	@AppStorage("SelectedEndpointID", store: Preferences.userDefaults)
	public var selectedEndpointID: Endpoint.ID?

//	@AppStorage("DisplaySummary", store: Preferences.userDefaults)
//	public var displaySummary = false

	/// Display ``ContainersView`` as grid
	@AppStorage("ContainersView.UseGrid", store: Preferences.userDefaults)
	public var cvUseGrid = true

	/// Include limited stacks in ``StacksView``
	@AppStorage("StacksView.IncludeLimitedStacks", store: Preferences.userDefaults)
	public var svIncludeLimitedStacks = false

	/// Filter stacks by active endpoint in ``StacksView``
	@AppStorage("StacksView.FilterByActiveEndpoint", store: Preferences.userDefaults)
	public var svFilterByActiveEndpoint = false

	/// Should logs include timestamps in ``ContainerLogsView``?
	@AppStorage("ContainerLogsView.IncludeTimestamps", store: Preferences.userDefaults)
	public var clIncludeTimestamps = true

	/// Should lines be separated in ``ContainerLogsView``?
	@AppStorage("ContainerLogsView.SeparateLines", store: Preferences.userDefaults)
	public var clSeparateLines = true

	/// When removing containers, should they be force-removed?
	@AppStorage("ContainerRemove.Force", store: Preferences.userDefaults)
	public var containerRemoveForce = false

	/// When removing containers, should associated volumes be also removed?
	@AppStorage("ContainerRemove.Volumes", store: Preferences.userDefaults)
	public var containerRemoveVolumes = false

	private init() { }
}

// MARK: - Preferences+Handlers

private extension Preferences {
	#if os(iOS)
	func onEnableBackgroundRefreshChange(_ isEnabled: Bool) {
		logger.debug("Background refresh enabled: \(isEnabled, privacy: .public)")

		if isEnabled {
			// Ask for permission
			Task {
				do {
					let allowed = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .providesAppNotificationSettings])
					logger.debug("Notifications authorization allowed: \(allowed, privacy: .public)")

					if !allowed {
						await MainActor.run {
							self.enableBackgroundRefresh = false
						}
					}
				} catch {
					self.logger.error("Error requesting notifications authorization: \(error.localizedDescription, privacy: .public)")
					await MainActor.run {
						self.enableBackgroundRefresh = false
					}
				}
			}
		} else {
			// Remove background refreshes and pending notifications
			BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundHelper.TaskIdentifier.backgroundRefresh)
			UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationHelper.NotificationIdentifier.containersChanged])
		}
	}
	#endif
}
