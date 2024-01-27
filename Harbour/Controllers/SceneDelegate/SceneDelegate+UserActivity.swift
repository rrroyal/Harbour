//
//  SceneDelegate+UserActivity.swift
//  Harbour
//
//  Created by royal on 19/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import PortainerKit
import SwiftUI
import UserNotifications

extension SceneDelegate {
	@MainActor
	func onContinueUserActivity(_ userActivity: NSUserActivity) {
		logger.notice("Continuing userActivity: \(userActivity, privacy: .sensitive(mask: .hash))")

		switch userActivity.persistentIdentifier {
		case HarbourUserActivityIdentifier.containerDetails:
			guard let navigationItem = try? userActivity.typedPayload(ContainerDetailsView.NavigationItem.self) else {
				logger.warning("Invalid payload in userActivity!")
				return
			}

			Task { @MainActor in
				resetSheets()
				navigate(to: .containers, with: navigationItem)
			}
		case HarbourUserActivityIdentifier.stackDetails:
			guard let navigationItem = try? userActivity.typedPayload(StackDetailsView.NavigationItem.self) else {
				logger.warning("Invalid payload in userActivity!")
				return
			}

			Task { @MainActor in
				resetSheets()
				navigate(to: .stacks, with: navigationItem)
			}
		default:
			break
		}
	}

	@MainActor
	func onScenePhaseChange(from previousScenePhase: ScenePhase, to newScenePhase: ScenePhase) {
		scenePhase = newScenePhase

		switch newScenePhase {
		case .background:
			#if os(iOS)
			BackgroundHelper.scheduleBackgroundRefreshIfNeeded()
			#endif
		case .inactive:
			break
		case .active:
			switch activeTab {
			case .containers:
				if PortainerStore.shared.containersTask?.isCancelled ?? true {
					PortainerStore.shared.refreshContainers()
				}
			case .stacks:
				if PortainerStore.shared.stacksTask?.isCancelled ?? true {
					PortainerStore.shared.refreshStacks()
				}
			}
		@unknown default:
			break
		}
	}

	@MainActor
	func onNotificationsToHandleChange(before: Set<UNNotificationResponse>, after: Set<UNNotificationResponse>) {
		guard scenePhase == .active || scenePhase == .background else { return }

		for response in after {
			switch response.notification.request.content.categoryIdentifier {
			case NotificationHelper.NotificationIdentifier.containersChanged:
				let userInfo = response.notification.request.content.userInfo
				guard let changedIDs = userInfo[NotificationHelper.UserInfoKey.changedIDs] as? [Container.ID] else { continue }
				let endpointID = userInfo[NotificationHelper.UserInfoKey.endpointID] as? Endpoint.ID

				if let changedID = changedIDs.first, changedIDs.count == 1 {
					guard let existingContainer = PortainerStore.shared.containers.first(where: { $0.id == changedID }) else {
						activeAlert = .init(title: "Alert.ContainerNotFound.Title", message: "Alert.ContainerNotFound.Message ContainerID:\(changedID)")
						continue
					}

					let navigationItem = ContainerDetailsView.NavigationItem(id: changedID, displayName: existingContainer.displayName, endpointID: endpointID)

					Task { @MainActor in
						resetSheets()
						navigate(to: .containers, with: navigationItem)
					}
				}
			default:
				continue
			}

			AppState.shared.notificationHandled(response)
		}
	}
}
