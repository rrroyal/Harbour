//
//  Endpoint+init.swift
//  Harbour
//
//  Created by royal on 04/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Endpoint {
	init(storedEndpoint: StoredEndpoint) {
		self.init(
			authorizedTeams: nil,
			authorizedUsers: nil,
			edgeID: nil,
			groupID: nil,
			id: storedEndpoint.id,
			name: storedEndpoint.name,
			publicURL: nil,
			status: nil,
			tls: nil,
			tagIDs: nil,
			tags: nil,
			type: nil,
			url: nil
		)
	}
}
