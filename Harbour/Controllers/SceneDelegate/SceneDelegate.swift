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

@Observable
final class SceneDelegate: NSObject {

	// MARK: Properties

	let logger = Logger(.scene)
	let indicators = Indicators()

	// MARK: Navigation

	@MainActor
	var scenePhase: ScenePhase?

	@MainActor
	var activeTab: ViewTab = .containers

	@MainActor
	var navigationPathContainers = NavigationPath()
	@MainActor
	var navigationPathStacks = NavigationPath()

	// MARK: Sheets

	var isLandingSheetPresented = !Preferences.shared.landingDisplayed
	var isSettingsSheetPresented = false
	var isCreateStackSheetPresented = false
	var isContainerChangesSheetPresented = false

	var activeCreateStackSheetDetent: PresentationDetent = .medium
	var handledCreateSheetDetentUpdate = false

	// MARK: Alerts

	var activeAlert: Alert?

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

	var selectedStackName: String?

	var viewsToFocus: Set<AnyHashable> = []
}

// MARK: - SceneDelegate+Actions

extension SceneDelegate {
	func onLandingDismissed() {
		Preferences.shared.landingDisplayed = true
	}
}
