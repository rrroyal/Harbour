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
		static let selectedEndpoint = "SelectedEndpoint"

		static let cvDisplaySummary = "CVDisplaySummary"
		static let cvUseColumns = "CVUseColumns"
		static let cvUseGrid = "CVUseGrid"
	}
}
