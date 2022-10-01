//
//  AppState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation
import os.log

// MARK: - AppState

/// Main place for all of the app-related state management.
final class AppState: ObservableObject {

	// MARK: Static properties

	static let shared: AppState = AppState()

	// MARK: Internal properties

	// swiftlint:disable:next force_unwrapping
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppState")

	// MARK: init

	private init() {}

}
