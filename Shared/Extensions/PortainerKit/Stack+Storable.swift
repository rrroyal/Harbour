//
//  Stack+init.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Stack: Storable {
	typealias Stored = StoredStack

	static func fromStored(_ stored: Stored) -> Self {
		Self(
			id: stored.id,
			name: stored.name,
			type: stored.type,
			endpointID: stored.endpointID
		)
	}

	func toStored() -> Stored {
		Stored(
			id: self.id,
			type: self.type,
			name: self.name,
			endpointID: self.endpointID
		)
	}
}
