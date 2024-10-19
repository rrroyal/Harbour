//
//  View+withEnvironment.swift
//  Harbour
//
//  Created by royal on 17/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftData
import SwiftUI

extension View {
	@ViewBuilder
	func withEnvironment(
		appState: AppState = .shared,
		preferences: Preferences = .shared,
		portainerStore: PortainerStore = .shared
	) -> some View {
		self
			.environment(appState)
			.environment(\.ikEnableHaptics, preferences.enableHaptics)
			.environmentObject(portainerStore)
			.environmentObject(preferences)
	}
}
