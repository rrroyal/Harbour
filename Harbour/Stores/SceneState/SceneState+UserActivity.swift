//
//  SceneState+UserActivity.swift
//  Harbour
//
//  Created by royal on 01/10/2022.
//

import Foundation

extension SceneState {
	@MainActor
	func onOpenURL(_ url: URL) {
		logger.notice("Opening from URL: \(url.absoluteString, privacy: .sensitive(mask: .hash)) [\(String._debugInfo(), privacy: .public)]")

		guard let harbourURL = HarbourURLScheme.fromURL(url) else { return }
		switch harbourURL {
			case .containerDetails(let id, let displayName, let endpointID):
				let navigationItem = ContainersView.ContainerNavigationItem(id: id, displayName: displayName, endpointID: endpointID)
				navigationPath.removeLast(navigationPath.count)
				navigationPath.append(navigationItem)
		}
	}

	@MainActor
	func onContinueContainerDetailsActivity(_ userActivity: NSUserActivity) {
		logger.notice("Continuing userActivity: \(userActivity, privacy: .sensitive(mask: .hash)) [\(String._debugInfo(), privacy: .public)]")

		guard let navigationItem = try? userActivity.typedPayload(ContainersView.ContainerNavigationItem.self) else {
			logger.warning("No payload in userActivity! [\(String._debugInfo(), privacy: .public)]")
			return
		}

		navigationPath.removeLast(navigationPath.count)
		navigationPath.append(navigationItem)
	}
}
