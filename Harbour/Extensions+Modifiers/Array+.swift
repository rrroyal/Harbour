//
//  Array+.swift
//  Harbour
//
//  Created by unitears on 04/10/2021.
//

import Foundation
import PortainerKit

extension Array where Element == PortainerKit.Container {
	func filtered(query: String) -> Self {
		guard !query.isReallyEmpty else { return self }
		
		let lowercasedQuery = query.lowercased()
		return filter {
			($0.displayName ?? "").lowercased().contains(lowercasedQuery) ||
			$0.id.lowercased().contains(lowercasedQuery) ||
			$0.imageID.contains(lowercasedQuery) ||
			($0.names ?? []).contains(where: { $0.lowercased().contains(lowercasedQuery) })
		}
	}
}
