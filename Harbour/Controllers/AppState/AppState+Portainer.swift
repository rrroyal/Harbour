//
//  AppState+Portainer.swift
//  Harbour
//
//  Created by royal on 29/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CoreSpotlight
import Foundation
import PortainerKit
import WidgetKit

// MARK: - AppState+PortainerActions

extension AppState {
	@discardableResult
	func switchPortainerServer(to serverURL: URL) -> Task<Void, Error> {
//		logger.notice("Switching Portainer server to \"\(serverURL.absoluteString, privacy: .sensitive(mask: .hash))\"")

		portainerServerSwitchTask?.cancel()
		let task = Task {
			defer { self.portainerServerSwitchTask = nil }

			let portainerStore = PortainerStore.shared
			do {
				guard !Task.isCancelled else { return }
				portainerStore.switchServer(to: serverURL)

				_ = try await portainerStore.refreshEndpoints().value
				try? await Task.sleep(for: .seconds(0.1))

				if portainerStore.selectedEndpoint != nil {
					portainerStore.refreshContainers()
				}

				portainerStore.refreshStacks()
			} catch {
				logger.error("Failed to switch Portainer server: \(error, privacy: .public)")
				throw error
			}
		}
		portainerServerSwitchTask = task
		return task
	}
}

// MARK: - AppState+PortainerData

extension AppState {
	func onContainersChange(from previousContainers: [Container], to newContainers: [Container]) {
//		WidgetCenter.shared.reloadTimelines(ofKind: HarbourWidgetKind.containerStatus)

//		Task {
//			await NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: [HarbourUserActivityIdentifier.containerDetails])
//		}

		Task.detached {
			try? await SpotlightHelper.indexContainers(newContainers)
		}
	}

	func onStacksChange(from previousStacks: [Stack], to newStacks: [Stack]) {
//		Task {
//			WidgetCenter.shared.reloadTimelines(ofKind: HarbourWidgetKind.stackStatus)
//			await NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: [HarbourUserActivityIdentifier.stackDetails])
//		}
		Task.detached {
			try? await SpotlightHelper.indexStacks(newStacks)
		}
	}
}
