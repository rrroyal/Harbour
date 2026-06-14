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
import PortainerKit
import SwiftUI

// MARK: - SceneDelegate

@Observable @MainActor
final class SceneDelegate: NSObject {

	// MARK: Properties

	let logger = Logger(.scene)
	let indicators = Indicators()

	// swiftlint:disable implicitly_unwrapped_optional
	@ObservationIgnored private(set) var portainerStore: PortainerStore!
	@ObservationIgnored private(set) var appState: AppState!
	@ObservationIgnored private(set) var preferences: Preferences!
	// swiftlint:enable implicitly_unwrapped_optional

	// MARK: Navigation

	var scenePhase: ScenePhase?

	var activeTab: ViewTab = .containers

	var navigationState = NavigationState()

	// MARK: Sheets

	var isLandingSheetPresented: Bool = false
	var isSettingsSheetPresented = false
	var isCreateStackSheetPresented = false
	var isContainerChangesSheetPresented = false

	// MARK: Containers

	var containerToRemove: Container?
	var isRemoveContainerAlertPresented: Binding<Bool> {
		.init(
			get: { self.containerToRemove != nil },
			set: { isPresented in
				if !isPresented {
					self.containerToRemove = nil
				}
			}
		)
	}

	// MARK: Stacks

	var stackToRemove: Stack?
	var isRemoveStackAlertPresented: Binding<Bool> {
		.init(
			get: { self.stackToRemove != nil },
			set: { isPresented in
				if !isPresented {
					self.stackToRemove = nil
				}
			}
		)
	}

	var editedStack: Stack?

	var selectedStackNameForContainersView: String?
	var selectedStackNameForStacksView: String?
}

// MARK: - SceneDelegate+Configuration

extension SceneDelegate {
	func configure(portainerStore: PortainerStore, appState: AppState, preferences: Preferences) {
		self.portainerStore = portainerStore
		self.appState = appState
		self.preferences = preferences
		self.isLandingSheetPresented = !preferences.landingDisplayed
	}
}

// MARK: - SceneDelegate+Actions

extension SceneDelegate {
	func onLandingDismissed() {
		preferences.landingDisplayed = true
	}
}
