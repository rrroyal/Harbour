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
	var id: Container.ID

	@Attribute(.unique)
	var persistentID: String?

	var name: String?
	var lastState: Container.State?
	var image: String?
	var associationID: String?

	init(id: ID, name: String?, lastState: Container.State?, image: String?, associationID: String?, persistentID: String?) {
		self.id = id
		self.name = name
		self.lastState = lastState
		self.image = image
		self.associationID = associationID
		self.persistentID = persistentID
	}

	convenience init(container: Container) {
		self.init(
			id: container.id,
			name: container.displayName,
			lastState: container.state,
			image: container.image,
			associationID: container.associationID,
			persistentID: container._persistentID
		)
	}
}
