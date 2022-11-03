//
//  Preferences+Keys.swift
//  Harbour
//
//  Created by royal on 02/11/2022.
//

import Foundation

extension Preferences {
	enum Keys {
		static let landingDisplayed = "LandingDisplayed"
		static let enableHaptics = "EnableHaptics"

		static let enableBackgroundRefresh = "EnableBackgroundRefresh"
		#if DEBUG
		static let lastBackgroundRefreshDate = "LastBackgroundRefreshDate"
		#endif

		static let selectedServer = "SelectedServer"
		static let selectedEndpointID = "SelectedEndpointID"

		static let cvUseGrid = "CVUseGrid"
	}
}
