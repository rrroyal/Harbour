//
//  KeyValueEntry.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

struct KeyValueEntry: Identifiable, Hashable {
	var id: Int { hashValue }

	var key: String
	var value: String

	init(_ key: String, _ value: String) {
		self.key = key
		self.value = value
	}
}
