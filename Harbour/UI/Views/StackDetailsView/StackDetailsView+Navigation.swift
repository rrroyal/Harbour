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
import SwiftUI

extension StackDetailsView: Deeplinkable {
	typealias DeeplinkDestination = Deeplink.StackDetailsDestination

	struct NavigationItem: NavigableItem, Identifiable, Codable {
		let stackID: String
		let stackName: String?

		var id: String {
			stackID
		}

		init(stackID: String, stackName: String? = nil) {
			self.stackID = stackID
			self.stackName = stackName
		}

		init(from deeplink: DeeplinkDestination) {
			self.stackID = deeplink.stackID
			self.stackName = deeplink.stackName
		}
	}

	enum Subdestination: Hashable {
		case environment([Stack.EnvironmentEntry]?)
	}

	var deeplinkDestination: DeeplinkDestination {
		.init(
			stackID: navigationItem.stackID,
			stackName: navigationItem.stackName
		)
	}

	static func handleNavigation(_ navigationPath: inout NavigationPath, with deeplink: DeeplinkDestination) {
		navigationPath.removeLast(navigationPath.count)

		let navigationItem = NavigationItem(from: deeplink)
		navigationPath.append(navigationItem)

//		if let subdestination = deeplink.subdestination, !subdestination.isEmpty {
//			subdestination
//				.compactMap { Subdestination(rawValue: $0.lowercased()) }
//				.forEach { navigationPath.append($0) }
//		}
	}
}
