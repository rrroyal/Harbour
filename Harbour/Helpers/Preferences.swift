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

	@AppStorage(Keys.landingDisplayed.rawValue) public var landingDisplayed: Bool = false
	@AppStorage(Keys.enableHaptics.rawValue) public var enableHaptics: Bool = true

	#if DEBUG
	@AppStorage(Keys.lastBackgroundRefreshDate.rawValue) public var lastBackgroundRefreshDate: TimeInterval?
	#endif

	@AppStorage(Keys.selectedServer.rawValue) public var selectedServer: String?
	@AppStorage(Keys.selectedEndpointID.rawValue) public var selectedEndpointID: Int?

	@AppStorage(Keys.cvUseGrid.rawValue) public var cvUseGrid: Bool = false

	private init() {}
}

// MARK: - Preferences+Keys

extension Preferences {
	enum Keys: String, CaseIterable {
		case landingDisplayed = "LandingDisplayed"
		case enableHaptics = "EnableHaptics"

		#if DEBUG
		case lastBackgroundRefreshDate = "LastBackgroundRefreshDate"
		#endif

		case selectedServer = "SelectedServer"
		case selectedEndpointID = "SelectedEndpointID"

		case cvUseGrid = "CVUseGrid"
	}
}
