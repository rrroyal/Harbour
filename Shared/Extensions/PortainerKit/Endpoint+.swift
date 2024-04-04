//
//  Endpoint+.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - Endpoint+_isStored

extension Endpoint {
	/// Is this endpoint not-live (i.e. created from ``StoredEndpoint``)?
	var _isStored: Bool {
		status == nil
	}
}

// MARK: - [Endpoint]+sorted

extension [Endpoint] {
	func sorted() -> Self {
		sorted { ("\($0.id)", $0.name ?? "") < ("\($1.id)", $1.name ?? "") }
	}
}
