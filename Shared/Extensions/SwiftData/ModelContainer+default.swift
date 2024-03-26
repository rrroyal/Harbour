//
//  ModelContainer+default.swift
//  Harbour
//
//  Created by royal on 28/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftData

extension ModelContainer {
	static func `default`() throws -> ModelContainer {
		try ModelContainer(for: StoredContainer.self)
	}
}
