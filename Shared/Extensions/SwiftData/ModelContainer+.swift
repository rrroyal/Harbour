//
//  ModelContainer+.swift
//  Harbour
//
//  Created by royal on 04/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftData

extension ModelContainer {
	static func `default`() throws -> ModelContainer {
		try ModelContainer(for: StoredContainer.self, StoredEndpoint.self)
	}

	static var allModelTypes: [any PersistentModel.Type] {
		[
			StoredContainer.self,
			StoredEndpoint.self
		]
	}
}
