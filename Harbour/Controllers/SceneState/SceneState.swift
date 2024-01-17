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

@Observable
final class SceneState {
	let logger = Logger(.custom(SceneState.self))
	let indicators = Indicators()

	var isSettingsSheetPresented = false
	var isStacksSheetPresented = false
	var navigationPath = NavigationPath()
}
