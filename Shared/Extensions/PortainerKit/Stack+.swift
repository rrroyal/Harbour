//
//  Stack+.swift
//  Harbour
//
//  Created by royal on 07/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import Foundation
import PortainerKit

// MARK: - [Stack]+sorted

extension [Stack] {
	func sorted() -> Self {
		sorted { ("\($0.name)", $0.id) < ("\($1.name)", $1.id) }
	}
}

// MARK: - [Stack]+filter

extension [Stack] {
	func filter(_ query: String) -> Self {
		if query.isReallyEmpty { return self }
		return filter {
			$0.name.localizedCaseInsensitiveContains(query) ||
			"\($0.id)".localizedCaseInsensitiveContains(query)
		}
	}
}
