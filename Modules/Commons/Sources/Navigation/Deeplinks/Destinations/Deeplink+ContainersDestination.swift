//
//  Deeplink+ContainersDestination.swift
//  Navigation
//
//  Created by royal on 03/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// MARK: - Deeplink+ContainersDestination

public extension Deeplink {
	struct ContainersDestination {
		public init() { }
	}
}

// MARK: - Deeplink.ContainersDestination+Deeplink.Destination

extension Deeplink.ContainersDestination: Deeplink.Destination {
	public var host: Deeplink.Host {
		.containers
	}

	public var url: URL? {
		var components = URLComponents()
		components.scheme = Deeplink.scheme
		components.host = self.host.rawValue

		return components.url
	}

	public init?(from components: URLComponents) { }
}
