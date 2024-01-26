//
//  Preferences+Key.swift
//  Harbour
//
//  Created by royal on 02/11/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

extension Preferences {
	enum Key {
		static let landingDisplayed = "LandingDisplayed"
		static let enableHaptics = "EnableHaptics"

		static let enableBackgroundRefresh = "EnableBackgroundRefresh"
		static let lastBackgroundRefreshDate = "LastBackgroundRefreshDate"

		static let selectedServer = "SelectedServer"
		static let selectedEndpoint = "SelectedEndpoint"

		static let cvDisplaySummary = "CVDisplaySummary"
		static let cvUseColumns = "CVUseColumns"
		static let cvUseGrid = "CVUseGrid"
	}
}
