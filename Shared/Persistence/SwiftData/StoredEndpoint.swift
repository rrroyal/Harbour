//
//  StoredEndpoint.swift
//  Harbour
//
//  Created by royal on 10/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftData

@Model
final class StoredEndpoint: Identifiable {
	@Attribute(.unique)
	var id: Endpoint.ID
	var name: String?

	init(id: ID, name: String?) {
		self.id = id
		self.name = name
	}

	convenience init(endpoint: Endpoint) {
		self.init(
			id: endpoint.id,
			name: endpoint.name
		)
	}
}
