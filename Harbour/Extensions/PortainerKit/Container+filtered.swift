//
//  Container+filtered.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import Foundation
import PortainerKit

extension [Container] {
	func filtered(query: String) -> Self {
		let lowercasedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
		if lowercasedQuery.isEmpty { return self }
		return filter {
			$0.names?.contains(where: { $0.lowercased().contains(lowercasedQuery) }) ?? false
		}
	}
}
