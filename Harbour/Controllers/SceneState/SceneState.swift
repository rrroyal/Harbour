//
//  SceneState.swift
//  Harbour
//
//  Created by royal on 19/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonOSLog
import IndicatorsKit
import OSLog
import SwiftUI

// MARK: - SceneState

@Observable
final class SceneState: IndicatorPresentable {
	let logger = Logger(.scene)
	let indicators = Indicators()

	var scenePhase: ScenePhase?

	var activeTab: ContentView.ViewTab = .containers
	var navigationPathContainers = NavigationPath()
	var navigationPathStacks = NavigationPath()

	var isLandingSheetPresented = !Preferences.shared.landingDisplayed
	var isSettingsSheetPresented = false

	var selectedStackName: String?

	var activeAlert: Alert?
}

// MARK: - SceneState+Actions

extension SceneState {
	func onLandingDismissed() {
		Preferences.shared.landingDisplayed = true
	}
}
