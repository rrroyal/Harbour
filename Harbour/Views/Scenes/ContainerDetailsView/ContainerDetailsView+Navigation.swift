//
//  ContainerDetailsView+NavigationItem.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit
import SwiftUI

extension ContainerDetailsView: Deeplinkable {
	struct NavigationItem: NavigableItem {
		enum CodingKeys: String, CodingKey {
			case id
			case displayName
			case endpointID
		}

		let id: Container.ID
		let displayName: String?
		let endpointID: Endpoint.ID?
	}

	enum Subdestination: String {
		/// Subdestination for ``ContainerDetailsView.LabelsDetailsView``.
		case labels
		/// Subdestination for ``ContainerDetailsView.EnvironmentDetailsView``.
		case environment
		/// Subdestination for ``ContainerDetailsView.PortsDetailsView``.
		case ports
		/// Subdestination for ``ContainerDetailsView.MountsDetailsView``.
		case mounts
		/// Subdestination for ``ContainerLogsView``.
		case logs
	}

	var destination: HarbourDeeplink.Destination {
		.containerDetails(id: navigationItem.id, displayName: navigationItem.displayName, endpointID: navigationItem.endpointID)
	}

	@MainActor
	static func handleNavigation(_ navigationPath: inout NavigationPath, with deeplink: HarbourDeeplink) {
		guard case .containerDetails(let id, let displayName, let endpointID) = deeplink.destination else {
			return
		}

		navigationPath.removeLast(navigationPath.count)

		let navigationItem = NavigationItem(id: id, displayName: displayName, endpointID: endpointID)
		navigationPath.append(navigationItem)

		if let subdestination = deeplink.subdestination {
			subdestination
				.compactMap { Subdestination(rawValue: $0) }
				.forEach { navigationPath.append($0) }
		}
	}
}
