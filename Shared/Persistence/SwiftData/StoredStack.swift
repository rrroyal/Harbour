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
	let id: Stack.ID
	let type: Stack.StackType
	let name: String
	let endpointID: Endpoint.ID

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

	init(stack: Stack) {
		self.id = stack.id
		self.type = stack.type
		self.name = stack.name
		self.endpointID = stack.endpointID
	}
}
