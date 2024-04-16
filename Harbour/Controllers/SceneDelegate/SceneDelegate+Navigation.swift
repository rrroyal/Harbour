//
//  SceneDelegate+Navigation.swift
//  Harbour
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import Navigation

extension SceneDelegate: DeeplinkHandlable {
	@MainActor
	func resetNavigation() {
		isSettingsSheetPresented = false
	}

	@MainActor
	func navigate(to tab: ContentView.ViewTab) {
		resetNavigation()
		activeTab = tab
	}

	@MainActor
	func handleURL(_ url: URL) {
		logger.notice("Opening from URL: \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\"")

		guard let destination = Deeplink.destination(from: url) else { return }
		// swiftlint:disable force_cast
		switch destination.host {
		case .containerDetails:
			typealias DestinationView = ContainerDetailsView

			navigate(to: .containers)
			DestinationView.handleNavigation(&navigationPathContainers, with: destination as! DestinationView.DeeplinkDestination)
		case .settings:
			resetNavigation()
			isSettingsSheetPresented = true
		}
		// swiftlint:enable force_cast
	}
}
