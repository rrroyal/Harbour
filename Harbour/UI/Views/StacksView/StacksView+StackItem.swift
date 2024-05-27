//
//  StacksView+StackItem.swift
//  Harbour
//
//  Created by royal on 13/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension StacksView {
	struct StackItem: Identifiable, Hashable {
		enum StackType {
			case stack
			case limited
		}

		var id: String
		var stackType: StackType
		var stack: Stack?
		var name: String

		init(stack: Stack) {
			self.id = stack.id.description
			self.stackType = .stack
			self.stack = stack
			self.name = stack.name
		}

		init(label: String) {
			self.id = "limited.\(label)"
			self.stackType = .limited
			self.stack = nil
			self.name = label
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
			hasher.combine(stackType)
			hasher.combine(name)
		}
	}
}
