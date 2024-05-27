//
//  SceneDelegate.swift
//  Harbour
//
//  Created by royal on 16/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonOSLog
import IndicatorsKit
import OSLog
import SwiftUI

// MARK: - SceneDelegate

@Observable
final class SceneDelegate: NSObject {
	let logger = Logger(.scene)
	let indicators = Indicators()

	var scenePhase: ScenePhase?

	var activeTab: ViewTab = .containers

	var navigationPathContainers = NavigationPath()
	var navigationPathStacks = NavigationPath()

	var isLandingSheetPresented = !Preferences.shared.landingDisplayed
	var isSettingsSheetPresented = false

	var selectedStackName: String?

	var activeAlert: Alert?

	var viewsToFocus: Set<AnyHashable> = []
}

// MARK: - SceneDelegate+Actions

extension SceneDelegate {
	func onLandingDismissed() {
		Preferences.shared.landingDisplayed = true
	}
}
