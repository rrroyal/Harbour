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
		let stackID: String
		let stackName: String?

		var id: String {
			stackID
		}

		init(stackID: String, stackName: String? = nil) {
			self.stackID = stackID
			self.stackName = stackName
		}

		init(stack: Stack) {
			self.stackID = stack.id.description
			self.stackName = stack.name
		}
	}

	enum Subdestination: Hashable {
		case environment([Stack.EnvironmentEntry]?)
	}
}
