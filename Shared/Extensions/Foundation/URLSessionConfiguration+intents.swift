//
//  URLSessionConfiguration+intents.swift
//  Harbour
//
//  Created by royal on 01/11/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
	/// URLSessionConfiguration for background tasks.
	static var intents: URLSessionConfiguration {
		let configuration = URLSessionConfiguration.default
		configuration.allowsConstrainedNetworkAccess = true
		configuration.allowsCellularAccess = true
//		configuration.allowsExpensiveNetworkAccess = true
//		configuration.isDiscretionary = false
		configuration.shouldUseExtendedBackgroundIdleMode = true
		configuration.timeoutIntervalForRequest = 5
		configuration.timeoutIntervalForResource = 5
		return configuration
	}
}
