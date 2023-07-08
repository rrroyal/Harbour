//
//  AppState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import CommonOSLog
import Foundation
import OSLog

// MARK: - AppState

/// Main place for all of the app-related state management.
final class AppState: ObservableObject {

	// MARK: Static Properties

	static let shared = AppState()

	// MARK: Internal Properties

	internal let logger = Logger(category: String(describing: AppState.self))
	internal let loggerBackground = Logger(category: Logger.Category.background)

	internal var portainerServerSwitchTask: Task<Void, Error>?

	// MARK: Public Properties

	@Published var alertContent: String?

	// MARK: init

	private init() { }

}
