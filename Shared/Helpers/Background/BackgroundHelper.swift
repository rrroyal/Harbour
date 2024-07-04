//
//  BackgroundHelper.swift
//  Harbour
//
//  Created by royal on 03/02/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import BackgroundTasks
import CommonFoundation
import CommonOSLog
import Foundation
import OSLog
import PortainerKit
import SwiftData
import UserNotifications

// MARK: - BackgroundHelper

/// Helper for background-related tasks.
struct BackgroundHelper: Sendable {
	internal static let logger = Logger(.custom(BackgroundHelper.self))
	internal static let loggerBackground = Logger(.background)

	/// Handles the containers change, providing a notificaion if needed.
	/// - Parameters:
	///   - oldContainers: Old (pre-update) containers
	///   - newContainers: New (post-update) containers
	///   - endpoint: Endpoint associated with this refresh
	@Sendable
	static func handleContainersUpdate(from oldContainers: [Container], to newContainers: [Container], endpoint: Endpoint) async throws {
		let oldMapping = oldContainers.reduce(into: [:]) { $0[$1._persistentID] = $1 }
		let newMapping = newContainers.reduce(into: [:]) { $0[$1._persistentID] = $1 }

		// Find any changes from `oldMapping` to `newMapping`
		var changes: [ContainerChange] = newMapping
			.compactMap { key, newContainer in
				let change: ContainerChange?
				if let oldContainer = oldMapping[key] {
					// Had old container, check if it was changed or re-created
					let changeType: ContainerChange.ChangeType? = if oldContainer.id != newContainer.id {
						.recreated
					} else if oldContainer.state != newContainer.state {
						.changed
					} else {
						// It's the same, ignore
						nil
					}
					guard let changeType else { return nil }

					change = ContainerChange(
						oldContainer: oldContainer,
						newContainer: newContainer,
						endpointID: endpoint.id,
						changeType: changeType
					)
				} else {
					// No old container, so it must be a new one
					change = ContainerChange(
						oldContainer: nil,
						newContainer: newContainer,
						endpointID: endpoint.id,
						changeType: .created
					)
				}

				guard let change else {
					loggerBackground.warning("Unable to create ContainerChange for id: \(key, privacy: .sensitive(mask: .hash))!")
					return nil
				}
				return change
			}

		// Check if there are any identifiers not present in `newMapping`
		let removedIdentifiers = Set(oldMapping.map(\.key)).subtracting(newMapping.map(\.key))
		changes += removedIdentifiers.compactMap { oldIdentifier in
			guard let oldContainer = oldMapping[oldIdentifier] else {
				return nil
			}
			guard let change = ContainerChange(
				oldContainer: oldContainer,
				newContainer: nil,
				endpointID: endpoint.id,
				changeType: .removed
			) else {
				loggerBackground.warning("Unable to create ContainerChange for id: \(oldIdentifier, privacy: .sensitive(mask: .hash))!")
				return nil
			}
			return change
		}

		changes = changes
//			.filter { $0.changeType == .recreated ? $0.oldState != $0.newState : true }
			.localizedSorted(by: \.containerName)

		loggerBackground.notice("Changes (\(changes.count, privacy: .public)): \(changes, privacy: .sensitive)")

		if changes.isEmpty {
			return
		}

		#if TARGET_APP
		let _changes = changes
		Task { @MainActor in
			AppState.shared.lastContainerChanges = _changes
		}
		#endif

		if let notificationContent = NotificationHelper.notificationContent(for: changes) {
			let notificationIdentifier = "\(NotificationHelper.NotificationIdentifier.containersChanged).\(changes.description.hashValue)"
			let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: nil)
			try await UNUserNotificationCenter.current().add(notificationRequest)
		} else {
			loggerBackground.warning("notificationContent(for:) didn't return anything!")
		}
	}
}

// MARK: - BackgroundHelper+BackgroundRefresh

extension BackgroundHelper {
	#if os(iOS)
	/// Schedules a new background refresh task.
	@Sendable
	static func scheduleBackgroundRefreshIfNeeded() {
		guard Preferences.shared.enableBackgroundRefresh else {
			logger.debug("Background refresh is disabled.")
			return
		}

		let identifier = TaskIdentifier.backgroundRefresh

		logger.notice("Scheduling background refresh with identifier: \"\(identifier, privacy: .public)\"")

		let request = BGAppRefreshTaskRequest(identifier: identifier)
		request.earliestBeginDate = .now

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			logger.error("Error scheduling background task with identifier: \"\(request.identifier, privacy: .public)\": \(error, privacy: .public)")
		}
	}
	#endif

	#if TARGET_APP
	/// Handles the background refresh task.
	@Sendable
	static func handleBackgroundRefresh() async {
		do {
			loggerBackground.notice("Handling background refresh...")

			#if DEBUG
			Task { @MainActor in
				Preferences.shared.lastBackgroundRefreshDate = Date().timeIntervalSince1970
			}
			#endif

			#if os(iOS)
			scheduleBackgroundRefreshIfNeeded()
			#endif

			let portainerStore = PortainerStore(urlSessionConfiguration: .intents)
			if !portainerStore.isSetup {
				await portainerStore.setupInitially()
			}

			guard let endpoint = portainerStore.selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}

			let oldContainers = portainerStore.containers
			let newContainers = try await portainerStore.refreshContainers().value

			Task.detached {
				try? await SpotlightHelper.indexContainers(newContainers)
			}

			try await handleContainersUpdate(from: oldContainers, to: newContainers, endpoint: endpoint)
		} catch {
			loggerBackground.error("Error handling background refresh: \(error, privacy: .public)")
		}
	}
	#endif
}
