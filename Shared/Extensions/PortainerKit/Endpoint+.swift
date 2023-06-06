//
//  Endpoint+.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import Foundation
import PortainerKit

// MARK: - [Endpoint]+sorted

extension [Endpoint] {
	func sorted() -> Self {
		sorted { ("\($0.id)", $0.name ?? "") < ("\($1.id)", $1.name ?? "") }
	}
}
