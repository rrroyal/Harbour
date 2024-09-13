//
//  ContainerDetailsView+NavigationItem.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import Navigation
import PortainerKit
import SwiftUI

extension ContainerDetailsView: Deeplinkable {
	typealias DeeplinkDestination = Deeplink.ContainerDetailsDestination

	struct NavigationItem: NavigableItem, Identifiable, Codable {
		enum CodingKeys: String, CodingKey {
			case id
			case displayName
			case endpointID
			case persistentID
		}

		let id: Container.ID
		let displayName: String?
		let endpointID: Endpoint.ID?
		let persistentID: String?

		init(id: Container.ID, displayName: String?, endpointID: Endpoint.ID? = nil, persistentID: String? = nil) {
			self.id = id
			self.displayName = displayName
			self.endpointID = endpointID
			self.persistentID = persistentID
		}

		init(from deeplink: DeeplinkDestination) {
			self.id = deeplink.containerID
			self.displayName = deeplink.containerName
			self.endpointID = deeplink.endpointID
			self.persistentID = deeplink.persistentID
		}
	}

	enum Subdestination: String, Hashable {
		/// Subdestination for ``ContainerDetailsView.LabelsDetailsView``.
		case labels
		/// Subdestination for ``ContainerDetailsView.EnvironmentDetailsView``.
		case environment
		/// Subdestination for ``ContainerDetailsView.NetworkDetailsView``.
		case network
		/// Subdestination for ``ContainerDetailsView.MountsDetailsView``.
		case mounts
		/// Subdestination for ``ContainerLogsView``.
		case logs
	}

	var deeplinkDestination: DeeplinkDestination {
		.init(
			containerID: navigationItem.id,
			containerName: navigationItem.displayName,
			endpointID: navigationItem.endpointID
		)
	}

	static func handleNavigation(_ navigationPath: inout NavigationPath, with deeplink: DeeplinkDestination) {
		let navigationItem = NavigationItem(from: deeplink)
		navigationPath.append(navigationItem)

		if let subdestination = deeplink.subdestination, !subdestination.isEmpty {
			subdestination
				.compactMap { Subdestination(rawValue: $0.lowercased()) }
				.forEach { navigationPath.append($0) }
		}
	}
}
