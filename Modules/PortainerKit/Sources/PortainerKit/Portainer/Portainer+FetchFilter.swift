//
//  Portainer+FetchFilter.swift
//  PortainerKit
//
//  Created by royal on 31/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// MARK: - Portainer+FetchFilters

public extension Portainer {
	struct FetchFilters: Codable {
		public let id: [Container.ID]?
		public let name: [String]?
		public let label: [String]?

		public init(
			id: [Container.ID]? = nil,
			name: [String]? = nil,
			label: [String]? = nil
		) {
			self.id = id
			self.name = name
			self.label = label
		}
	}
}
