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

	init(id: Container.ID, name: String?) {
		self.id = id
		self.name = name
	}

	init(container: Container) {
		self.id = container.id
		self.name = container.displayName
	}
}
