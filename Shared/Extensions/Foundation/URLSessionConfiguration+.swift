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
		configuration.isDiscretionary = false
		// configuration.shouldUseExtendedBackgroundIdleMode = true
		// configuration.waitsForConnectivity = true
		return configuration
	}

	/// `URLSessionConfiguration` for background tasks.
	static var backgroundTasks: URLSessionConfiguration {
		let configuration = URLSessionConfiguration.app
		configuration.timeoutIntervalForRequest = 10
		configuration.timeoutIntervalForResource = 10
		configuration.waitsForConnectivity = false
		return configuration
	}
}
