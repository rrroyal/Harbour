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
