//
//  ContainerNavigationItem.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
import PortainerKit

struct ContainerNavigationItem: NavigationItem {
	enum CodingKeys: String, CodingKey {
		case id
		case displayName
		case endpointID
	}

	let id: Container.ID
	let displayName: String?
	let endpointID: Endpoint.ID?
}
