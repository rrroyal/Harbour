//
//  SceneDelegate+Navigation.swift
//  Harbour
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Navigation
import SwiftUI

// MARK: - SceneDelegate+DeeplinkHandlable

extension SceneDelegate: DeeplinkHandlable {
	@MainActor
	func resetSheets() {
		isLandingSheetPresented = false
		isSettingsSheetPresented = false
		stackSheet = nil
		isContainerChangesSheetPresented = false
	}

	@MainActor
	func navigate<each Destination: NavigableItem>(to tab: ViewTab, with navigationItems: repeat each Destination, removingPrevious removePreviousItems: Bool = true) {
		activeTab = tab

		switch tab {
		case .containers:
			if removePreviousItems {
				navigationState.containersNavigationPath = .init()
				navigationState.containerNavigationItem = nil
			}

			for navigationItem in repeat each navigationItems {
				navigationState.containersNavigationPath.append(navigationItem)
			}
		case .stacks:
			if removePreviousItems {
				navigationState.stacksNavigationPath = .init()
				navigationState.stackNavigationItem = nil
			}

			for navigationItem in repeat each navigationItems {
				navigationState.stacksNavigationPath.append(navigationItem)
			}
		}
	}

	@MainActor
	func handleURL(_ url: URL) {
		logger.notice("Opening from URL: \"\(url.absoluteString)\"")

		guard let destination = Deeplink.destination(from: url) else {
			logger.warning("Failed to create Deeplink.Destination from URL: \"\(url.absoluteString)\"")
			return
		}

		resetSheets()

		// swiftlint:disable force_cast
		switch destination.host {
		case .containers:
			navigate(to: .containers)
		case .containerDetails:
			typealias DestinationView = ContainerDetailsView
			let destination = destination as! DestinationView.DeeplinkDestination

			navigate(to: .containers)

			DestinationView.handleNavigation(&navigationState.containersNavigationPath, with: destination)
			navigationState.containerNavigationItem = DestinationView.NavigationItem(from: destination)
		case .stacks:
			navigate(to: .stacks)
		case .stackDetails:
			typealias DestinationView = StackDetailsView
			let destination = destination as! DestinationView.DeeplinkDestination

			navigate(to: .stacks)

			DestinationView.handleNavigation(&navigationState.stacksNavigationPath, with: destination)
			navigationState.stackNavigationItem = DestinationView.NavigationItem(stackID: destination.stackID, stackName: destination.stackName)
		case .settings:
			isSettingsSheetPresented = true
		}
		// swiftlint:enable force_cast
	}
}

// MARK: - SceneDelegate+NavigationState

extension SceneDelegate {
	struct NavigationState {
		var containersNavigationPath = NavigationPath()
		var containerNavigationItem: ContainerDetailsView.NavigationItem?

		var stacksNavigationPath = NavigationPath()
		var stackNavigationItem: StackDetailsView.NavigationItem?
	}
}
