//
//  StoredStack.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit
import SwiftData

@Model
final class StoredStack: Identifiable {
	@Attribute(.unique)
	var id: Stack.ID
	var type: Stack.StackType
	var name: String
	var endpointID: Endpoint.ID

	init(
		id: Stack.ID,
		type: Stack.StackType,
		name: String,
		endpointID: Endpoint.ID
	) {
		self.id = id
		self.type = type
		self.name = name
		self.endpointID = endpointID
	}

	convenience init(stack: Stack) {
		self.init(
			id: stack.id,
			type: stack.type,
			name: stack.name,
			endpointID: stack.endpointID
		)
	}
}
