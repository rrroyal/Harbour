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
		logger.info("Opening from URL: \(url.absoluteString, privacy: .public) [\(String.debugInfo(), privacy: .public)]")

		guard let harbourURL = HarbourURLScheme.fromURL(url) else { return }
		switch harbourURL {
			case .containerDetails(let id, let displayName):
				let navigationItem = ContainersView.ContainerNavigationItem(id: id, displayName: displayName, endpointID: nil)
				navigationPath.removeLast(navigationPath.count)
				navigationPath.append(navigationItem)
		}
	}

	@MainActor
	func onContinueContainerDetailsActivity(_ userActivity: NSUserActivity) {
		logger.info("Continuing userActivity: \(userActivity, privacy: .sensitive) [\(String.debugInfo(), privacy: .public)]")

		guard let navigationItem = try? userActivity.typedPayload(ContainersView.ContainerNavigationItem.self) else {
			logger.warning("No payload in userActivity! [\(String.debugInfo(), privacy: .public)]")
			return
		}

		navigationPath.removeLast(navigationPath.count)
		navigationPath.append(navigationItem)
	}
}
