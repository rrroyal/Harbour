//
//  Deeplink+ContainerDetailsDestination.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// MARK: - Deeplink+ContainerDetailsDestination

public extension Deeplink {
	struct ContainerDetailsDestination {
		public let containerID: String
		public let containerName: String?
		public let endpointID: Int?
		public let persistentID: String?
		public let subdestination: [String]?

		public init(containerID: String, containerName: String?, endpointID: Int?, persistentID: String? = nil, subdestination: [String]? = nil) {
			self.containerID = containerID
			self.containerName = containerName
			self.endpointID = endpointID
			self.persistentID = persistentID
			self.subdestination = subdestination
		}
	}
}

// MARK: - Deeplink.ContainerDetailsDestination+Deeplink.Destination

extension Deeplink.ContainerDetailsDestination: Deeplink.Destination {
	public var host: Deeplink.Host {
		.containerDetails
	}

	public var url: URL? {
		var components = URLComponents()
		components.scheme = Deeplink.scheme
		components.host = self.host.rawValue

		components.path = "/" + containerID

		var queryItems: [URLQueryItem] = []

		if let persistentID {
			queryItems.append(.init(name: Deeplink.QueryKey.persistentID.rawValue, value: persistentID))
		}

		if let endpointID {
			queryItems.append(.init(name: Deeplink.QueryKey.endpointID.rawValue, value: endpointID.description))
		}

		if let containerName {
			queryItems.append(.init(name: Deeplink.QueryKey.name.rawValue, value: containerName))
		}

		components.queryItems = queryItems

		return components.url
	}

	public init?(from components: URLComponents) {
		let path = components.path.split(separator: "/")

		guard let containerID = path.first else { return nil }
		self.containerID = String(containerID)

		self.containerName = components.queryItems?.value(for: .name)
		self.persistentID = components.queryItems?.value(for: .persistentID)

		self.endpointID = if let str = components.queryItems?.value(for: .endpointID) {
			Int(str)
		} else {
			nil
		}

		let subdestination = path
			.dropFirst()
			.map { $0.lowercased() }
		self.subdestination = subdestination
	}
}
