//
//  IdentifiableTuple.swift
//  Harbour
//
//  Created by royal on 02/07/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

struct IdentifiableTuple<K: Hashable, V: Hashable>: Identifiable, Hashable {
	var id: String {
		"\(key.hashValue):\(value.hashValue)"
	}

	let key: K
	let value: V
}
