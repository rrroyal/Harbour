//
//  Endpoint+init.swift
//  Harbour
//
//  Created by royal on 04/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Endpoint: Storable {
	typealias Stored = StoredEndpoint

	static func fromStored(_ stored: Stored) -> Self {
		self.init(
			authorizedTeams: nil,
			authorizedUsers: nil,
			edgeID: nil,
			groupID: nil,
			id: stored.id,
			name: stored.name,
			publicURL: nil,
			status: nil,
			tls: nil,
			tagIDs: nil,
			tags: nil,
			type: nil,
			url: nil
		)
	}

	func toStored() -> Stored {
		Stored(
			id: self.id,
			name: self.name
		)
	}
}
