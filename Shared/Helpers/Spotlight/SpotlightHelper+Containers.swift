//
//  SpotlightHelper+Containers.swift
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

extension SpotlightHelper {
	static func indexContainers(_ containers: [Container], endpointID: Endpoint.ID?, serverURL: URL?) async throws {
		logger.debug("Indexing \(containers.count) containers...")

		let index = CSSearchableIndex.default()

		do {
			try await index.deleteSearchableItems(withDomainIdentifiers: [DomainIdentifier.container])
		} catch {
			logger.error("Failed to de-index stacks: \(error.localizedDescription, privacy: .public)")
		}

		let items = containers.map { container in
			let attributes = CSSearchableItemAttributeSet(contentType: .url)
			attributes.identifier = container.id
			attributes.domainIdentifier = DomainIdentifier.container
			attributes.title = container.displayName ?? container.id
			attributes.contentDescription = container.id
			attributes.contentType = UTType.url.identifier
			attributes.contentURL = PortainerDeeplink(baseURL: serverURL)?.containerURL(containerID: container.id, endpointID: endpointID)

			let containerNames = container.namesNormalized
			attributes.alternateNames = containerNames?.count == 1 ? nil : containerNames
			attributes.keywords = [
				container.id
			] + (containerNames ?? [])

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
			logger.error("Failed to index containers: \(error.localizedDescription, privacy: .public)")
		}
	}
}
