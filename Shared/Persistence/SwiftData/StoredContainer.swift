//
//  StoredContainer.swift
//  Harbour
//
//  Created by royal on 12/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
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
	let image: String?
	let associationID: String?

	init(id: Container.ID, name: String?, lastState: ContainerState?, image: String, associationID: String?) {
		self.id = id
		self.name = name
		self.lastState = lastState
		self.image = image
		self.associationID = associationID
	}

	init(container: Container) {
		self.id = container.id
		self.name = container.displayName
		self.lastState = container.state
		self.image = container.image
		self.associationID = container.associationID
	}
}
