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
		if query.isReallyEmpty { return self }
		return filter {
			$0.names?.contains(where: { $0.localizedCaseInsensitiveContains(query) }) ?? false
		}
	}
}
