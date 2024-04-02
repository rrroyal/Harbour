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

@Observable @MainActor
final class SceneState {
	let logger = Logger(.scene)
	let indicators = Indicators()

	var scenePhase: ScenePhase?

	var navigationPath = NavigationPath()

	var isSettingsSheetPresented = false
	var isStacksSheetPresented = false

	var activeAlert: Alert?
}
