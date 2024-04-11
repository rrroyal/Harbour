//
//  StackDetailsView+Navigation.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import Navigation
import PortainerKit

extension StackDetailsView: Navigable {
	struct NavigationItem: Hashable, Identifiable {
		let stackID: Stack.ID
		let stackName: String?

		var id: Stack.ID {
			stackID
		}

		init(stackID: Stack.ID, stackName: String? = nil) {
			self.stackID = stackID
			self.stackName = stackName
		}

		init(stack: Stack) {
			self.stackID = stack.id
			self.stackName = stack.name
		}
	}

	enum Subdestination: Hashable {
		case environment
	}
}
