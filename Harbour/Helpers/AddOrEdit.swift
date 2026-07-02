//
//  AddOrEdit.swift
//  Harbour
//
//  Created by royal on 15/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

enum AddOrEdit<T> {
	case add
	case edit(T)

	var id: Int {
		switch self {
		case .add: 0
		case .edit: 1
		}
	}

	var unwrapped: T? {
		switch self {
		case .add:
			nil
		case .edit(let t):
			t
		}
	}
}

extension AddOrEdit: Identifiable where T: Identifiable {}

extension AddOrEdit: Equatable where T: Equatable {}

extension AddOrEdit: Hashable where T: Hashable {}
