//
//  SceneDelegate+UserActivity.swift
//  Harbour
//
//  Created by royal on 19/12/2022.
//

import Foundation
import CommonFoundation

extension SceneDelegate {
	@MainActor
	func onOpenURL(_ url: URL) {
		logger.notice("Opening from URL: \(url.absoluteString, privacy: .sensitive(mask: .hash)) [\(String._debugInfo(), privacy: .public)]")

		guard let harbourURL = HarbourURLScheme.fromURL(url) else { return }
		switch harbourURL {
			case .containerDetails(let id, let displayName, let endpointID):
				let navigationItem = ContainerNavigationItem(id: id, displayName: displayName, endpointID: endpointID)
				isSettingsSheetPresented = false
				navigationPath.removeLast(navigationPath.count)
				navigationPath.append(navigationItem)
		}
	}

	@MainActor
	func onContinueContainerDetailsActivity(_ userActivity: NSUserActivity) {
		logger.notice("Continuing userActivity: \(userActivity, privacy: .sensitive(mask: .hash)) [\(String._debugInfo(), privacy: .public)]")

		guard let navigationItem = try? userActivity.typedPayload(ContainerNavigationItem.self) else {
			logger.warning("Invalid payload in userActivity! [\(String._debugInfo(), privacy: .public)]")
			return
		}

		isSettingsSheetPresented = false
		navigationPath.removeLast(navigationPath.count)
		navigationPath.append(navigationItem)
	}
}
