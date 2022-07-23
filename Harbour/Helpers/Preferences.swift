//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import SwiftUI

// MARK: - Preferences

/// UserDefaults wrapper; main preferences store
final class Preferences: ObservableObject {
	public static let shared: Preferences = Preferences()
	public static let ud: UserDefaults = .group

	@AppStorage(Keys.finishedSetup.rawValue) public var finishedSetup: Bool = false

	@AppStorage(Keys.enableHaptics.rawValue) public var enableHaptics: Bool = true

	@AppStorage(Keys.cvUseGrid.rawValue) public var cvUseGrid: Bool = false

	private init() {}
}

// MARK: - Preferences+Keys

extension Preferences {
	enum Keys: String, CaseIterable {
		case finishedSetup = "FinishedSetup"

		case enableHaptics = "EnableHaptics"

		case cvUseGrid = "CVUseGrid"
	}
}
