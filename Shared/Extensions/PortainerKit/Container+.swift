//
//  Container+.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import Foundation
import PortainerKit

// MARK: - Container+

extension Container {
	/// Display name of this container.
	var displayName: String? {
		guard let firstName = names?.first else { return nil }
		return firstName.starts(with: "/") ? String(firstName.dropFirst()) : firstName
	}

	var namesNormalized: [String]? {
		names?.map {
			$0.starts(with: "/") ? String($0.dropFirst()) : $0
		}
	}

	/// Name of the stack associated with this container.
	var stack: String? {
		labels?.first { $0.key.lowercased() == ContainerLabel.stack.lowercased() }?.value
	}

	/// ID of Harbour container association.
	var associationID: String? {
		labels?.first { $0.key.lowercased() == ContainerLabel.associationID.lowercased() }?.value
	}

	/// Exit code of this container.
	var exitCode: Int? {
		guard let status else { return nil }

		let regex = /Exited \((\d*)\).*/
		guard let firstMatch = status.firstMatch(of: regex) else { return nil }
		let str = firstMatch.output.1
		return Int(str)
	}

	/// Is this container not-live (i.e. created from ``StoredContainer``)?
	var _isStored: Bool {
		status == nil && imageID == nil && created == nil
	}

	/// Internal ID for this container, basing on `names`, `image` and `associationID`.
	var _persistentID: Int {
		var hasher = Hasher()
		if let associationID {
			hasher.combine(associationID)
		} else {
			hasher.combine(names)
			hasher.combine(image)
		}
		return hasher.finalize()
	}
}

// MARK: - [Container]+

extension [Container] {
	/// Returns an array of elements sorted by `displayName` (or `id` if `displayName` is missing).
	func sorted() -> Self {
		sorted { ($0.displayName ?? $0.id).localizedStandardCompare($1.displayName ?? $1.id) == .orderedAscending }
	}

	/// Returns an array of elements filtered by `query`.
	/// Filters the elements by taking `names`, `id` (and `stack` if `includingStacks` is equal to `true`) into account.
	/// - Parameters:
	///   - query: Query to filter by
	///   - includingStacks: Should elements be filtered by also taking the `stack` property into account?
	/// - Returns: Filtered array of elements, or `self` if `query` is empty.
	func filter(_ query: String, includingStacks: Bool = false) -> Self {
		if query.isReallyEmpty { return self }
		return filter {
			$0.names?.contains(where: { $0.localizedCaseInsensitiveContains(query) }) ?? false ||
			$0.id.localizedCaseInsensitiveContains(query) ||
			(includingStacks ? ($0.stack?.localizedCaseInsensitiveContains(query) ?? false) : false)
		}
	}
}
