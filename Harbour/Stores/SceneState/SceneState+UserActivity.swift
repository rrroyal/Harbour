//
//  SceneState+UserActivity.swift
//  Harbour
//
//  Created by royal on 01/10/2022.
//

import Foundation

extension SceneState {
	func onContinueContainerDetailsActivity(_ userActivity: NSUserActivity) {
		logger.info("Continuing userActivity: \(userActivity, privacy: .sensitive) [\(String.debugInfo(), privacy: .public)]")

		guard let data = try? userActivity.typedPayload(ContainersView.ContainerNavigationItem.self) else {
			logger.warning("No payload in userActivity! [\(String.debugInfo(), privacy: .public)]")
			return
		}

		navigationPath.append(data)
	}
}
