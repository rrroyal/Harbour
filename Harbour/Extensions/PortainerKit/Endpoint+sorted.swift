//
//  Endpoint+sorted.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import Foundation
import PortainerKit

extension [Endpoint] {
	func sorted() -> Self {
		sorted { ($0.name ?? "", $0.id.description) > ($1.name ?? "", $1.id.description) }
	}
}
