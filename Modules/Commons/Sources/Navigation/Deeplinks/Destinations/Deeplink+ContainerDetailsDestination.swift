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
		public let subdestination: [String]?

		public init(containerID: String, containerName: String?, endpointID: Int?, subdestination: [String]? = nil) {
			self.containerID = containerID
			self.containerName = containerName
			self.endpointID = endpointID
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

		components.queryItems = [
			.init(name: Deeplink.QueryKey.name.rawValue, value: containerName)
		]

		if let endpointID {
			components.queryItems?.append(.init(name: Deeplink.QueryKey.endpointID.rawValue, value: endpointID.description))
		}

		return components.url
	}

	public init?(from components: URLComponents) {
		let path = components.path.split(separator: "/")

		guard let containerID = path.first else { return nil }
		self.containerID = String(containerID)

		self.containerName = components.queryItems?.value(for: .name)

		let endpointID: Int? = if let endpointIDStr = components.queryItems?.value(for: .endpointID) {
			Int(endpointIDStr)
		} else {
			nil
		}
		self.endpointID = endpointID

		let subdestination = path
			.dropFirst()
			.map { $0.lowercased() }
		self.subdestination = subdestination
	}
}
