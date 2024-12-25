//
//  URLSessionConfiguration+.swift
//  Harbour
//
//  Created by royal on 01/11/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
	/// `URLSessionConfiguration` for app-wide usage.
	static var app: URLSessionConfiguration {
		let configuration = URLSessionConfiguration.default
		configuration.allowsConstrainedNetworkAccess = true
		configuration.httpAdditionalHeaders = [
			"Accept-Encoding": "gzip, deflate"
		]
		configuration.shouldUseExtendedBackgroundIdleMode = true
//		configuration.waitsForConnectivity = true
		return configuration
	}

	/// `URLSessionConfiguration` for intents.
	static var intents: URLSessionConfiguration {
		let configuration = URLSessionConfiguration.default
//		configuration.allowsConstrainedNetworkAccess = true
//		configuration.shouldUseExtendedBackgroundIdleMode = true
		configuration.timeoutIntervalForRequest = 5
		configuration.timeoutIntervalForResource = 5
		configuration.waitsForConnectivity = true
		return configuration
	}
}
