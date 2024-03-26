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
	func handleURL(_ url: URL) {
		logger.notice("Opening from URL: \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\"")

		guard let destination = Deeplink.destination(from: url) else { return }
		// swiftlint:disable force_cast
		switch destination.host {
		case .containerDetails:
			typealias DestinationView = ContainerDetailsView

			isSettingsSheetPresented = false
			DestinationView.handleNavigation(&navigationPath, with: destination as! DestinationView.DeeplinkDestination)
		case .settings:
			isSettingsSheetPresented = true
		}
		// swiftlint:enable force_cast
	}
}
