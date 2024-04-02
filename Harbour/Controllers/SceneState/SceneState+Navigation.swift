//
//  SceneState+Navigation.swift
//  Harbour
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import Navigation

extension SceneState: DeeplinkHandlable {
	@MainActor
	func resetNavigation() {
		isSettingsSheetPresented = false
		isStacksSheetPresented = false
	}

	@MainActor
	func handleURL(_ url: URL) {
		logger.notice("Opening from URL: \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\"")

		guard let destination = Deeplink.destination(from: url) else { return }
		// swiftlint:disable force_cast
		switch destination.host {
		case .containerDetails:
			typealias DestinationView = ContainerDetailsView

			resetNavigation()
			DestinationView.handleNavigation(&navigationPath, with: destination as! DestinationView.DeeplinkDestination)
		case .settings:
			resetNavigation()
			isSettingsSheetPresented = true
		}
		// swiftlint:enable force_cast
	}
}
