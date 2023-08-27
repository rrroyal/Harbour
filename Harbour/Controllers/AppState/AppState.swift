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

// MARK: - AppState

/// Main place for all of the app-related state management.
@Observable
final class AppState {

	// MARK: Static Properties

	static let shared = AppState()

	// MARK: Internal Properties

	internal let logger = Logger(.custom(AppState.self))
	internal let loggerBackground = Logger(.background)

	internal var portainerServerSwitchTask: Task<Void, Error>?

	// MARK: init

	private init() { }

}
