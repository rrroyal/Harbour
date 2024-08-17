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

	// MARK: Navigation

	var scenePhase: ScenePhase?

	var activeTab: ViewTab = .containers

	var navigationState = NavigationState()

	// MARK: Cross-view

	var viewsToFocus: Set<AnyHashable> = []

	// MARK: Sheets

	var isLandingSheetPresented = !Preferences.shared.landingDisplayed
	var isSettingsSheetPresented = false
	var isCreateStackSheetPresented = false
	var isContainerChangesSheetPresented = false

	var activeCreateStackSheetDetent: PresentationDetent = .medium
	var handledCreateSheetDetentUpdate = false

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

// MARK: - SceneDelegate+Actions

extension SceneDelegate {
	func onLandingDismissed() {
		Preferences.shared.landingDisplayed = true
	}
}
