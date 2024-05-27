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
		switch newScenePhase {
		case .background:
			#if os(iOS)
			BackgroundHelper.scheduleBackgroundRefreshIfNeeded()
			#endif
		case .inactive:
			break
		case .active:
			guard scenePhase != nil else { break } // ignore first launch
			guard PortainerStore.shared.refreshTask?.isCancelled ?? true else { break }

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

		scenePhase = newScenePhase
	}
}

// MARK: - SceneDelegate+Notifications

extension SceneDelegate {
	@MainActor
	func onNotificationsToHandleChange(before previousNotifications: Set<UNNotificationResponse>, after newNotifications: Set<UNNotificationResponse>) {
		guard scenePhase == .active || scenePhase == .background else { return }

		for response in newNotifications {
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

					resetSheets()
					navigate(to: .containers, with: navigationItem)
				}
			default:
				continue
			}

			AppState.shared.notificationHandled(response)
		}
	}
}
