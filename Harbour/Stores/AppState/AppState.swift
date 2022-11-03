//
//  AppState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation
import OSLog

// MARK: - AppState

/// Main place for all of the app-related state management.
final class AppState: ObservableObject {

	// MARK: Static properties

	static let shared = AppState()

	// MARK: Internal properties

	internal let logger = Logger(category: .appState)

	internal var portainerServerSwitchTask: Task<Void, Error>?

	// MARK: init

	private init() {}

}
