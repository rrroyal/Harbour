//
//  SceneDelegate+UserActivity.swift
//  Harbour
//
//  Created by royal on 19/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CoreSpotlight
import PortainerKit
import SwiftUI
import UserNotifications

// MARK: - SceneDelegate+UserActivity

extension SceneDelegate {
	@MainActor
	func onContinueUserActivity(_ userActivity: NSUserActivity) {
		logger.notice("Continuing UserActivity: \(userActivity, privacy: .sensitive(mask: .hash))")

		switch userActivity.persistentIdentifier {
		case HarbourUserActivityIdentifier.containerDetails:
			guard let navigationItem = try? userActivity.typedPayload(ContainerDetailsView.NavigationItem.self) else {
				logger.warning("Invalid payload in UserActivity!")
				return
			}

			resetSheets()
			navigate(to: .containers, with: navigationItem)
		case HarbourUserActivityIdentifier.stackDetails:
			guard let navigationItem = try? userActivity.typedPayload(StackDetailsView.NavigationItem.self) else {
				logger.warning("Invalid payload in UserActivity!")
				return
			}

			resetSheets()
			navigate(to: .stacks, with: navigationItem)
		default:
			break
		}
	}
}

// MARK: - SceneDelegate+Spotlight

extension SceneDelegate {
	@MainActor
	func onSpotlightUserActivity(_ userActivity: NSUserActivity) {
		logger.notice("Continuing Spotlight UserActivity: \(userActivity, privacy: .sensitive(mask: .hash))")

		guard let activityIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
			logger.warning("No activity identifier in UserActivity!")
			return
		}

		let activityIdentifierSplit = activityIdentifier.split(separator: ".")
		guard let _itemIdentifier = activityIdentifierSplit.last else {
			logger.warning("No item identifier: \(activityIdentifierSplit, privacy: .public)")
			return
		}

		let itemIdentifier = String(_itemIdentifier)
		let typeIdentifier = activityIdentifierSplit.dropLast()

		switch typeIdentifier.joined(separator: ".") {
		case HarbourSpotlight.DomainIdentifier.container:
			let container = PortainerStore.shared.containers.first { $0.id == itemIdentifier }
			navigate(to: .containers, with: ContainerDetailsView.NavigationItem(id: itemIdentifier, displayName: container?.displayName, endpointID: nil))
		case HarbourSpotlight.DomainIdentifier.stack:
			let stack = PortainerStore.shared.stacks.first { $0.id.description == itemIdentifier }
			navigate(to: .stacks, with: StackDetailsView.NavigationItem(stackID: itemIdentifier, stackName: stack?.name))
		default:
			logger.warning("Invalid type identifier: \(typeIdentifier, privacy: .public)")
		}
	}
}

// MARK: - SceneDelegate+Scene

extension SceneDelegate {
	@MainActor
	func onScenePhaseChange(from previousScenePhase: ScenePhase, to newScenePhase: ScenePhase) {
		let isFirstRun = self.scenePhase == nil
		scenePhase = newScenePhase

		switch newScenePhase {
		case .background:
			#if os(iOS)
			BackgroundHelper.scheduleBackgroundRefreshIfNeeded()
			#endif
		case .inactive:
			break
		case .active:
			guard !isFirstRun else { break }

			let portainerStore = PortainerStore.shared
			guard portainerStore.isSetup else { break }

			switch activeTab {
			case .containers:
				if portainerStore.endpointsTask?.isCancelled ?? true {
					portainerStore.refreshEndpoints()
				}
				if portainerStore.containersTask?.isCancelled ?? true {
					portainerStore.refreshContainers()
				}
			case .stacks:
				if portainerStore.stacksTask?.isCancelled ?? true {
					portainerStore.refreshStacks()
				}
			}
		@unknown default:
			break
		}
	}
}

// MARK: - SceneDelegate+Notifications

extension SceneDelegate {
	@MainActor
	func onNotificationsToHandleChange(before previousNotifications: Set<UNNotificationResponse>, after newNotifications: Set<UNNotificationResponse>) {
		guard !newNotifications.isEmpty else { return }

		logger.notice("Handling new notifications (\(newNotifications.count)): \(newNotifications, privacy: .sensitive(mask: .hash))")

//		guard scenePhase == .active || scenePhase == .background else { return }

		for response in newNotifications {
			switch response.notification.request.content.categoryIdentifier {
			case NotificationHelper.NotificationIdentifier.containersChanged:
				let userInfo = response.notification.request.content.userInfo
				guard let data = userInfo[NotificationHelper.UserInfoKey.containerChanges] as? Data,
					  let changes: [ContainerChange] = try? NotificationHelper.decodeNotificationPayload(from: data), !changes.isEmpty else {
					continue
				}

				AppState.shared.lastContainerChanges = changes
				isContainerChangesSheetPresented = true
			default:
				continue
			}

			AppState.shared.notificationHandled(response)
		}
	}
}
