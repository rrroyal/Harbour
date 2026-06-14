//
//  AppState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonOSLog
import Foundation
import Observation
import OSLog
import UserNotifications

// MARK: - AppState

/// Main place for all of the app-related state management.
@Observable @MainActor
final class AppState {

	// MARK: Static Properties

	// MARK: Internal Properties

	internal let logger = Logger(.app)
	internal let portainerStore: PortainerStore

	internal var portainerServerSwitchTask: Task<Void, Error>?

	internal var notificationsToHandle: Set<UNNotificationResponse> = []

	// MARK: Public Properties

	var lastContainerChanges: [ContainerChange]?

	// MARK: init

	init(portainerStore: PortainerStore) {
		self.portainerStore = portainerStore
	}
}
