//
//  AppState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation
import os.log

final class AppState: ObservableObject {
	static let shared: AppState = AppState()

	// swiftlint:disable:next force_unwrapping
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppState")

	private init() {}
}
