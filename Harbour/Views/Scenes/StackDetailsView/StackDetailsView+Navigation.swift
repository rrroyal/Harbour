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

		var id: Stack.ID {
			stackID
		}
	}

	typealias Subdestination = Never
}
