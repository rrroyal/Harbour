//
//  Array+.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import Foundation
import PortainerKit

extension Array where Element == PortainerKit.Container {
	func sortedAndFiltered(query: String?) -> Self {
		let sorted = sorted { ($0.displayName ?? "", $0.id) < ($1.displayName ?? "", $1.id) }
		guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !query.isEmpty else { return sorted }
		
		return sorted.filter {
			($0.displayName ?? "").lowercased().contains(query) ||
			$0.id.lowercased().contains(query) ||
			$0.imageID.contains(query) ||
			($0.names ?? []).contains(where: { $0.lowercased().contains(query) })
		}
	}
}

extension Array where Element: Equatable {
	mutating func remove(_ item: Element) {
		removeAll(where: { $0 == item })
	}
}
