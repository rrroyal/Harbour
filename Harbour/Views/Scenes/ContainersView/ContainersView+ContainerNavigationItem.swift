//
//  ContainersView+ContainerNavigationItem.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import Foundation
import PortainerKit

extension ContainersView {
	struct ContainerNavigationItem: Hashable, Identifiable, Codable {
		let id: Container.ID
		let displayName: String?
		let endpointID: Endpoint.ID?
	}
}
