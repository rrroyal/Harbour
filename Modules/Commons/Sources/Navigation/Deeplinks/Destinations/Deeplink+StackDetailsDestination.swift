//
//  Deeplink+StackDetailsDestination.swift
//  Navigation
//
//  Created by royal on 18/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// MARK: - Deeplink+StackDetailsDestination

public extension Deeplink {
	struct StackDetailsDestination {
		public let stackID: String
		public let stackName: String?
//		public let endpointID: Int?
		public let subdestination: [String]?

		public init(stackID: String, stackName: String?, subdestination: [String]? = nil) {
			self.stackID = stackID
			self.stackName = stackName
			self.subdestination = subdestination
		}
	}
}

// MARK: - Deeplink.StackDetailsDestination+Deeplink.Destination

extension Deeplink.StackDetailsDestination: Deeplink.Destination {
	public var host: Deeplink.Host {
		.stackDetails
	}

	public var url: URL? {
		var components = URLComponents()
		components.scheme = Deeplink.scheme
		components.host = self.host.rawValue

		components.path = "/" + stackID

		components.queryItems = [
			.init(name: Deeplink.QueryKey.name.rawValue, value: stackName)
//			.init(name: Deeplink.QueryKey.endpointID.rawValue, value: endpointID?.description ?? "")
		]

		return components.url
	}

	public init?(from components: URLComponents) {
		let path = components.path.split(separator: "/")

		guard let stackID = path.first else { return nil }
		self.stackID = String(stackID)

		self.stackName = components.queryItems?.value(for: .name)

//		let endpointID: Int? = if let endpointIDStr = components.queryItems?.value(for: .endpointID) {
//			Int(endpointIDStr)
//		} else {
//			nil
//		}
//		self.endpointID = endpointID

		let subdestination = path
			.dropFirst()
			.map { $0.lowercased() }
		self.subdestination = subdestination
	}
}
