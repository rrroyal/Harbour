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
public final class Preferences: ObservableObject, @unchecked Sendable {

	public static let shared = Preferences()

	private let logger = Logger(.custom(Preferences.self))

	/// Was landing view displayed?
	@AppStorage("LandingDisplayed", store: .group!)
	public var landingDisplayed = false

	/// Are haptics enabled?
	@AppStorage("EnableHaptics", store: .group!)
	public var enableHaptics = true

	/// Is background refresh enabled?
	#if os(iOS)
	@AppStorage("EnableBackgroundRefresh", store: .group!)
	public var enableBackgroundRefresh = false {
		didSet { onEnableBackgroundRefreshChange(enableBackgroundRefresh) }
	}
	#endif

	/// Last background refresh time
	@AppStorage("LastBackgroundRefreshDate", store: .group!)
	public var lastBackgroundRefreshDate: TimeInterval?

	/// Selected server
	@AppStorage("SelectedServer", store: .group!)
	public var selectedServer: String?

	/// Selected endpoint
	@AppStorage("SelectedEndpointID", store: .group!)
	public var selectedEndpointID: Endpoint.ID?

//	@AppStorage("DisplaySummary", store: Preferences.userDefaults)
//	public var displaySummary = false

	/// Use two-columns layouts
	@AppStorage("UseColumns", store: .group!)
	public var useColumns = true

	/// Display ``ContainersView`` as grid
	@AppStorage("ContainersView.UseGrid", store: .group!)
	public var cvUseGrid = true

	/// Include limited stacks in ``StacksView``
	@AppStorage("StacksView.IncludeLimitedStacks", store: .group!)
	public var svIncludeLimitedStacks = false

	/// Filter stacks by active endpoint in ``StacksView``
	@AppStorage("StacksView.FilterByActiveEndpoint", store: .group!)
	public var svFilterByActiveEndpoint = false

	/// When removing containers, should they be force-removed?
	@AppStorage("ContainerRemove.Force", store: .group!)
	public var containerRemoveForce = false

	/// When removing containers, should associated volumes be also removed?
	@AppStorage("ContainerRemove.Volumes", store: .group!)
	public var containerRemoveVolumes = false

	private init() { }
}

// MARK: - Preferences+Handlers

private extension Preferences {
	#if os(iOS)
	func onEnableBackgroundRefreshChange(_ isEnabled: Bool) {

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
					self.logger.error("Error requesting notifications authorization: \(error, privacy: .public)")
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
