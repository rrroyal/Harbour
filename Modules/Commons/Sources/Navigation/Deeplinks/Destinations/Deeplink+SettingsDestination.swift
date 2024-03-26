//
//  Deeplink+SettingsDestination.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// MARK: - Deeplink+SettingsDestination

public extension Deeplink {
	struct SettingsDestination { }
}

// MARK: - Deeplink.SettingsDestination+Deeplink.Destination

extension Deeplink.SettingsDestination: Deeplink.Destination {
	public var host: Deeplink.Host {
		.settings
	}

	public var url: URL? {
		var components = URLComponents()
		components.scheme = Deeplink.scheme
		components.host = self.host.rawValue
		return components.url
	}

	public init?(from components: URLComponents) {
		self.init()
	}
}
