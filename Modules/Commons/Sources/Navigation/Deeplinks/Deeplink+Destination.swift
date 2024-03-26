//
//  Deeplink+Destination.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

public extension Deeplink {
	protocol Destination {
		var host: Deeplink.Host { get }
		var url: URL? { get }

		init?(from components: URLComponents)
	}
}
