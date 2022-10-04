//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import SwiftUI

// MARK: - Preferences

/// UserDefaults wrapper; user preferences store.
public final class Preferences: ObservableObject {
	public static let shared = Preferences()
	public static let ud: UserDefaults = .group

	@AppStorage(Keys.landingDisplayed.rawValue, store: .group) public var landingDisplayed = false
	@AppStorage(Keys.enableHaptics.rawValue, store: .group) public var enableHaptics = true

	#if DEBUG
	@AppStorage(Keys.lastBackgroundRefreshDate.rawValue, store: .group) public var lastBackgroundRefreshDate: TimeInterval?
	#endif

	@AppStorage(Keys.selectedServer.rawValue, store: .group) public var selectedServer: String?
	@AppStorage(Keys.selectedEndpointID.rawValue, store: .group) public var selectedEndpointID: Int?

	@AppStorage(Keys.cvUseGrid.rawValue, store: .group) public var cvUseGrid = false

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
