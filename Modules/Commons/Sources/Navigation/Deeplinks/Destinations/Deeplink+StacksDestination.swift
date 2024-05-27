//
//  Deeplink+StacksDestination.swift
//  Navigation
//
//  Created by royal on 03/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// MARK: - Deeplink+StacksDestination

public extension Deeplink {
	struct StacksDestination {
		public init() { }
	}
}

// MARK: - Deeplink.StacksDestination+Deeplink.Destination

extension Deeplink.StacksDestination: Deeplink.Destination {
	public var host: Deeplink.Host {
		.stacks
	}

	public var url: URL? {
		var components = URLComponents()
		components.scheme = Deeplink.scheme
		components.host = self.host.rawValue

		return components.url
	}

	public init?(from components: URLComponents) { }
}
