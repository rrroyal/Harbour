//
//  StoredContainer.swift
//  Harbour
//
//  Created by royal on 12/08/2023.
//

import Foundation
import PortainerKit
import SwiftData

@Model
final class StoredContainer: Identifiable {
	@Attribute(.unique)
	let id: Container.ID
	let name: String?
	let lastState: ContainerState?

	init(id: Container.ID, name: String?, lastState: ContainerState?) {
		self.id = id
		self.name = name
		self.lastState = lastState
	}

	init(container: Container) {
		self.id = container.id
		self.name = container.displayName
		self.lastState = container.state
	}
}
