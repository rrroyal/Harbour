//
//  SceneState+UserActivity.swift
//  Harbour
//
//  Created by royal on 19/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import Foundation

extension SceneState {
	@MainActor
	func onOpenURL(_ url: URL) {
		logger.notice("Opening from URL: \"\(url.absoluteString, privacy: .sensitive(mask: .hash))\"")

		guard let deeplink = HarbourDeeplink(from: url) else { return }
		switch deeplink.destination {
		case .containerDetails:
			typealias Destination = ContainerDetailsView

			isSettingsSheetPresented = false
			Destination.handleNavigation(&navigationPath, with: deeplink)
		case .settings:
			isSettingsSheetPresented = true
		case .none:
			break
		}
	}

	@MainActor
	func onContinueContainerDetailsActivity(_ userActivity: NSUserActivity) {
		logger.notice("Continuing userActivity: \(userActivity, privacy: .sensitive(mask: .hash))")

		guard let navigationItem = try? userActivity.typedPayload(ContainerDetailsView.NavigationItem.self) else {
			logger.warning("Invalid payload in userActivity!")
			return
		}

		isSettingsSheetPresented = false
		navigationPath.removeLast(navigationPath.count)
		navigationPath.append(navigationItem)
	}
}
