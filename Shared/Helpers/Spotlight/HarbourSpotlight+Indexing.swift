//
//  HarbourSpotlight+Indexing.swift
//  Harbour
//
//  Created by royal on 13/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonOSLog
import CoreSpotlight
import Foundation
import OSLog
import PortainerKit

extension HarbourSpotlight {
	/*
	static func index(_ items: [CSSearchableItem], index: CSSearchableIndex) async throws {
		logger.debug("Indexing \(items.count, privacy: .public) items...")

		do {
			// get old client state
			let storedClientState = try await index.fetchLastClientState()
			let storedClientStateIDs = (try? JSONDecoder().decode(Set<String>.self, from: storedClientState)) ?? Set()

			// create new client state from items
			let newIdentifiers = Set(items.compactMap(\.attributeSet.identifier))
			let newClientState = try JSONEncoder().encode(newIdentifiers)

			// begin batching
			index.beginBatch()

			// remove items with ids that are not in the newClientState
			let idsToRemove = storedClientStateIDs.subtracting(newIdentifiers)
			try await index.deleteSearchableItems(withIdentifiers: idsToRemove.map(HarbourSpotlight.ItemIdentifier.container))

			// re-map items with updates
			let items = items.map {
				if let identifier = $0.attributeSet.identifier {
					$0.isUpdate = storedClientStateIDs.contains(identifier)
				}
				return $0
			}

			// index items
			try await index.indexSearchableItems(items)

			// end batch
			try await index.endBatch(withClientState: newClientState)
		} catch {
			self.logger.error("Failed to index items: \(error, privacy: .public)")
			throw error
		}
	}
	 */

	/*
	static func indexContainers(_ containers: [Container]) async throws {
		#if TARGET_APP
		let portainerServerURL: URL? = PortainerStore.shared.serverURL
		let portainerEndpoint: Endpoint? = PortainerStore.shared.selectedEndpoint
		#else
		let portainerServerURL: URL? = nil
		let portainerEndpoint: Endpoint? = nil
		#endif
		let portainerDeeplink = PortainerDeeplink(baseURL: portainerServerURL)

		let items = containers.map { container in
			let attributes = CSSearchableItemAttributeSet(contentType: .url)
			attributes.identifier = container.id
			attributes.domainIdentifier = HarbourSpotlight.DomainIdentifier.container
			attributes.title = container.displayName ?? container.id
			attributes.contentDescription = container.id
			attributes.contentType = UTType.url.identifier
			attributes.contentURL = portainerDeeplink?.containerURL(containerID: container.id, endpointID: portainerEndpoint?.id)

			let containerNames = container.namesNormalized
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

		try await index(items, index: .containers)
	}
	 */

	/*
	static func indexContainers(_ containers: [Container]) async throws {
		#if TARGET_APP
		let portainerServerURL: URL? = PortainerStore.shared.serverURL
		let portainerEndpoint: Endpoint? = PortainerStore.shared.selectedEndpoint
		#else
		let portainerServerURL: URL? = nil
		let portainerEndpoint: Endpoint? = nil
		#endif
		let portainerDeeplink = PortainerDeeplink(baseURL: portainerServerURL)

		// create context
		let index = CSSearchableIndex.containers

		do {
			// begin batching
			let storedClientState = try await index.fetchLastClientState()
			index.beginBatch()

			// grab old client state, get old indexed container ids
			let storedClientStateIDs = (try? JSONDecoder().decode(Set<String>.self, from: storedClientState)) ?? Set()

			// create new client state from containers
			let newContainerIDs = Set(containers.map(\.id))
			let newClientState = try JSONEncoder().encode(newContainerIDs)

			// remove items with ids that are not in the newClientState
			let idsToRemove = storedClientStateIDs.subtracting(newContainerIDs)
			try await index.deleteSearchableItems(withIdentifiers: idsToRemove.map(HarbourSpotlight.ItemIdentifier.container))

			// create items to index
			let items = containers.map { container in
				let attributes = CSSearchableItemAttributeSet(contentType: .url)
				attributes.identifier = container.id
				attributes.domainIdentifier = HarbourSpotlight.DomainIdentifier.container
				attributes.title = container.displayName ?? container.id
				attributes.contentDescription = container.id
				attributes.contentType = UTType.url.identifier
				attributes.contentURL = portainerDeeplink?.containerURL(containerID: container.id, endpointID: portainerEndpoint?.id)

				let containerNames = container.namesNormalized
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
				item.isUpdate = storedClientStateIDs.contains(container.id)
				return item
			}

			// index items
			try await index.indexSearchableItems(items)

			// end batch
			try await index.endBatch(withClientState: newClientState)
		} catch {
			self.logger.error("Failed to index containers: \(error, privacy: .public)")
			throw error
		}
	}
	 */

	static func indexContainers(_ containers: [Container]) async throws {
		logger.debug("Indexing \(containers.count) containers...")

		let index = CSSearchableIndex.default()

		#if TARGET_APP
		let portainerEndpoint: Endpoint? = PortainerStore.shared.selectedEndpoint
		let portainerDeeplink: PortainerDeeplink? = PortainerDeeplink(baseURL: PortainerStore.shared.serverURL)
		#else
		let portainerEndpoint: Endpoint? = nil
		let portainerDeeplink: PortainerDeeplink? = nil
		#endif

		do {
			try await index.deleteSearchableItems(withDomainIdentifiers: [DomainIdentifier.stack])
		} catch {
			logger.error("Failed to de-index stacks: \(error, privacy: .public)")
		}

		let items = containers.map { container in
			let attributes = CSSearchableItemAttributeSet(contentType: .url)
			attributes.identifier = container.id
			attributes.domainIdentifier = DomainIdentifier.container
			attributes.title = container.displayName ?? container.id
			attributes.contentDescription = container.id
			attributes.contentType = UTType.url.identifier
			attributes.contentURL = portainerDeeplink?.containerURL(containerID: container.id, endpointID: portainerEndpoint?.id)

			let containerNames = container.namesNormalized
			attributes.alternateNames = containerNames?.count == 1 ? nil : containerNames
			attributes.keywords = [
				containerNames ?? [],
				[container.id]
			].flatMap { $0 }

			let item = CSSearchableItem(
				uniqueIdentifier: ItemIdentifier.container(id: container.id),
				domainIdentifier: DomainIdentifier.container,
				attributeSet: attributes
			)
			return item
		}

		do {
			if !items.isEmpty {
				try await index.indexSearchableItems(items)
			}
		} catch {
			logger.error("Failed to index containers: \(error, privacy: .public)")
		}
	}

	static func indexStacks(_ stacks: [Stack]) async throws {
		logger.debug("Indexing \(stacks.count) stacks...")

		let index = CSSearchableIndex.default()

		#if TARGET_APP
		let portainerDeeplink: PortainerDeeplink? = PortainerDeeplink(baseURL: PortainerStore.shared.serverURL)
		#else
		let portainerDeeplink: PortainerDeeplink? = nil
		#endif

		do {
			try await index.deleteSearchableItems(withDomainIdentifiers: [DomainIdentifier.stack])
		} catch {
			logger.error("Failed to de-index stacks: \(error, privacy: .public)")
		}

		let items = stacks
			.map { stack in
				let attributes = CSSearchableItemAttributeSet(contentType: .url)
				attributes.identifier = stack.id.description
				attributes.domainIdentifier = HarbourSpotlight.DomainIdentifier.stack
				attributes.title = stack.name
				attributes.contentDescription = stack.id.description
				attributes.contentType = UTType.url.identifier
				attributes.contentURL = portainerDeeplink?.stackURL(stack: stack)
				attributes.keywords = [
					stack.id.description,
					stack.name
				]

				let item = CSSearchableItem(
					uniqueIdentifier: ItemIdentifier.stack(id: stack.id),
					domainIdentifier: DomainIdentifier.stack,
					attributeSet: attributes
				)
				return item
			}

		do {
			if !items.isEmpty {
				try await index.indexSearchableItems(items)
			}
		} catch {
			logger.error("Failed to index stacks: \(error, privacy: .public)")
		}
	}
}
