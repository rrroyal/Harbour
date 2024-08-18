//
//  SpotlightHelper.swift
//  Harbour
//
//  Created by royal on 25/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonOSLog
import CoreSpotlight
import Foundation
import OSLog
import PortainerKit

// MARK: - SpotlightHelper

enum SpotlightHelper {
	static let logger = Logger(.custom(SpotlightHelper.self))

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
			try await index.deleteSearchableItems(withIdentifiers: idsToRemove.map(SpotlightHelper.ItemIdentifier.container))

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
}

// MARK: - SpotlightHelper+DomainIdentifier

// swiftlint:disable force_unwrapping
extension SpotlightHelper {
	enum DomainIdentifier {
		static let container = "\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!).Container"
		static let stack = "\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!).Stack"
	}
}
// swiftlint:enable force_unwrapping

// MARK: - SpotlightHelper+ItemIdentifier

extension SpotlightHelper {
	enum ItemIdentifier {
		@inlinable
		static func container(id containerID: Container.ID) -> String {
			"\(DomainIdentifier.container).\(containerID)"
		}

		@inlinable
		static func stack(id stackID: Stack.ID) -> String {
			"\(DomainIdentifier.stack).\(stackID)"
		}
	}
}
