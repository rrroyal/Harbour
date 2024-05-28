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
	func switchPortainerServer(to serverURL: URL) -> Task<Void, Error> {
//		logger.notice("Switching Portainer server to \"\(serverURL.absoluteString, privacy: .sensitive(mask: .hash))\"")

		portainerServerSwitchTask?.cancel()
		let task = Task {
			defer { self.portainerServerSwitchTask = nil }

			let portainerStore = PortainerStore.shared
			do {
				guard !Task.isCancelled else { return }
				try portainerStore.switchServer(to: serverURL)
				portainerStore.refreshEndpoints()
				portainerStore.refreshContainers()
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

		Task {
			let portainerDeeplink = PortainerDeeplink(baseURL: PortainerStore.shared.serverURL)
			let selectedEndpoint = PortainerStore.shared.selectedEndpoint

			do {
				try await CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [HarbourSpotlight.DomainIdentifier.container])
			} catch {
				self.logger.error("Failed to de-index containers: \(error, privacy: .public)")
			}

			let items = newContainers.map { container in
				let containerNames = container.namesNormalized

				let attributes = CSSearchableItemAttributeSet(contentType: .content)
				attributes.identifier = container.id
				attributes.relatedUniqueIdentifier = container.id
				attributes.domainIdentifier = HarbourSpotlight.DomainIdentifier.container
				attributes.title = container.displayName ?? container.id
				attributes.contentDescription = container.id
				attributes.contentURL = portainerDeeplink?.containerURL(containerID: container.id, endpointID: selectedEndpoint?.id)
				attributes.alternateNames = containerNames?.count == 1 ? nil : containerNames
				attributes.keywords = [
					containerNames ?? [],
					[container.id]
				].flatMap { $0 }

				let item = CSSearchableItem(
					uniqueIdentifier: HarbourSpotlight.ItemIdentifier.container(id: container.id),
					domainIdentifier: HarbourSpotlight.DomainIdentifier.container,
					attributeSet: attributes
				)
				return item
			}

			do {
				if !items.isEmpty {
					try await CSSearchableIndex.default().indexSearchableItems(items)
				}
			} catch {
				self.logger.error("Failed to index containers: \(error, privacy: .public)")
			}
		}
	}

	func onStacksChange(from previousStacks: [Stack], to newStacks: [Stack]) {
//		Task {
//			WidgetCenter.shared.reloadTimelines(ofKind: HarbourWidgetKind.stackStatus)
//			await NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: [HarbourUserActivityIdentifier.stackDetails])
//		}

		Task {
			let portainerDeeplink = PortainerDeeplink(baseURL: PortainerStore.shared.serverURL)

			do {
				try await CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [HarbourSpotlight.DomainIdentifier.stack])
			} catch {
				self.logger.error("Failed to de-index stacks: \(error, privacy: .public)")
			}

			let items = newStacks
				.map { stack in
					let attributes = CSSearchableItemAttributeSet(contentType: .content)
					attributes.identifier = stack.id.description
					attributes.relatedUniqueIdentifier = stack.id.description
					attributes.domainIdentifier = HarbourSpotlight.DomainIdentifier.stack
					attributes.title = stack.name
					attributes.contentDescription = stack.id.description
					attributes.contentURL = portainerDeeplink?.stackURL(stack: stack)
					attributes.keywords = [
						stack.id.description,
						stack.name
					]

					let item = CSSearchableItem(
						uniqueIdentifier: HarbourSpotlight.ItemIdentifier.stack(id: stack.id),
						domainIdentifier: HarbourSpotlight.DomainIdentifier.stack,
						attributeSet: attributes
					)
					return item
				}

			do {
				if !items.isEmpty {
					try await CSSearchableIndex.default().indexSearchableItems(items)
				}
			} catch {
				self.logger.error("Failed to index stacks: \(error, privacy: .public)")
			}
		}
	}
}
