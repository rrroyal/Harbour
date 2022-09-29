//
//  Container+sorted.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import Foundation
import PortainerKit

extension [Container] {
	func sorted() -> Self {
		sorted { ($0.displayName ?? "", $0.id) < ($1.displayName ?? "", $1.id) }
	}
}
