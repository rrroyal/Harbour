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

		guard let deeplink = HarbourDeeplink(url: url) else { return }
		switch deeplink {
		case .containerDetails(let id, let displayName, let endpointID):
			isSettingsSheetPresented = false
			navigationPath = .init()

			let navigationItem = ContainerNavigationItem(id: id, displayName: displayName, endpointID: endpointID)
			navigationPath.append(navigationItem)
		case .settings:
			isSettingsSheetPresented = true
		}
	}

	@MainActor
	func onContinueContainerDetailsActivity(_ userActivity: NSUserActivity) {
		logger.notice("Continuing userActivity: \(userActivity, privacy: .sensitive(mask: .hash))")

		guard let navigationItem = try? userActivity.typedPayload(ContainerNavigationItem.self) else {
			logger.warning("Invalid payload in userActivity!")
			return
		}

		isSettingsSheetPresented = false
		navigationPath = .init()
		navigationPath.append(navigationItem)
	}
}
