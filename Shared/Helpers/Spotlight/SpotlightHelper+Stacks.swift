//
//  SpotlightHelper+Stacks.swift
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
	static func indexStacks(_ stacks: [Stack]) async throws {
		logger.debug("Indexing \(stacks.count) stacks...")

		let index = CSSearchableIndex.default()

		let portainerDeeplink: PortainerDeeplink? = PortainerDeeplink(baseURL: PortainerStore.shared.serverURL)

		do {
			try await index.deleteSearchableItems(withDomainIdentifiers: [DomainIdentifier.stack])
		} catch {
			logger.error("Failed to de-index stacks: \(error, privacy: .public)")
		}

		let items = stacks
			.map { stack in
				let attributes = CSSearchableItemAttributeSet(contentType: .url)
				attributes.identifier = stack.id.description
				attributes.domainIdentifier = SpotlightHelper.DomainIdentifier.stack
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
