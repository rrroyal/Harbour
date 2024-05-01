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

					guard let change = ContainerChange(
						oldContainer: oldContainer,
						newContainer: newContainer,
						endpointID: endpoint.id,
						changeType: changeType
					) else {
						loggerBackground.warning("Unable to create ContainerChange!")
						return nil
					}
					return change
				} else {
					// No old container, so it must be a new one
					guard let change = ContainerChange(
						oldContainer: nil,
						newContainer: newContainer,
						endpointID: endpoint.id,
						changeType: .created
					) else {
						loggerBackground.warning("Unable to create ContainerChange!")
						return nil
					}
					return change
				}
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
				loggerBackground.warning("Unable to create ContainerChange!")
				return nil
			}
			return change
		}

		changes = changes
			.filter { $0.changeType == .recreated ? $0.oldState != $0.newState : true }
			.localizedSorted(by: \.containerName)

		loggerBackground.notice("Changes: \(changes)")

		if changes.isEmpty {
			return
		}

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

			let portainerStore = PortainerStore(urlSessionConfiguration: .backgroundTasks)
			if !portainerStore.isSetup {
				await portainerStore.setupInitially()
			}

			guard let endpoint = portainerStore.selectedEndpoint else {
				throw PortainerError.noSelectedEndpoint
			}

			let oldContainers = portainerStore.containers
//				.map { Container(id: $0.id, names: $0.names, image: $0.image, labels: $0.labels, state: $0.state, status: $0.status) }

			let newContainersTask = portainerStore.refreshContainers()
			let newContainers = try await newContainersTask.value
//				.map { Container(id: $0.id, names: $0.names, image: $0.image, labels: $0.labels, state: $0.state, status: $0.status) }

			try await handleContainersUpdate(from: oldContainers, to: newContainers, endpoint: endpoint)
		} catch {
			loggerBackground.error("Error handling background refresh: \(error, privacy: .public)")
		}
	}
	#endif
}
