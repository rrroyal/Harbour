//
//  KeyValueEntry.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// MARK: - KeyValueEntry

struct KeyValueEntry: Identifiable, Hashable {
	var id: Int { hashValue }

	var key: String
	var value: String

	init(_ key: String, _ value: String) {
		self.key = key
		self.value = value
	}
}

// MARK: - [KeyValueEntry]+sorted()

extension [KeyValueEntry] {
	func sorted() -> Self {
		sorted { ($0.key + $0.value).localizedCaseInsensitiveCompare($1.key + $1.value) == .orderedAscending }
	}
}
