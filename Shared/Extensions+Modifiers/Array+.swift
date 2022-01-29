//
//  Array+.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import Foundation
import PortainerKit

extension Array where Element == PortainerKit.Container {
	func filtered(query: String?) -> Self {
		guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else { return self }
		
		let lowercasedQuery = query.lowercased()
		return filter {
			($0.displayName ?? "").lowercased().contains(lowercasedQuery) ||
			$0.id.lowercased().contains(lowercasedQuery) ||
			$0.imageID.contains(lowercasedQuery) ||
			($0.names ?? []).contains(where: { $0.lowercased().contains(lowercasedQuery) })
		}
	}
}

extension Array where Element: Equatable {
	mutating func remove(_ item: Element) {
		removeAll(where: { $0 == item })
	}
}
