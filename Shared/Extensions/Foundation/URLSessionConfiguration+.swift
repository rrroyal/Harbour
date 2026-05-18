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
		let configuration = makeConfiguration(from: .default)

		return configuration
	}

	/// `URLSessionConfiguration` for intents.
	static var intents: URLSessionConfiguration {
		let configuration = makeConfiguration(from: .app)

		configuration.timeoutIntervalForRequest = 30
		configuration.timeoutIntervalForResource = 30

		return configuration
	}
}

private extension URLSessionConfiguration {
	static func makeConfiguration(from configuration: URLSessionConfiguration) -> URLSessionConfiguration {
		configuration.allowsConstrainedNetworkAccess = true
		configuration.httpAdditionalHeaders = [
			"Accept-Encoding": "gzip, deflate"
		]
		configuration.timeoutIntervalForRequest = 120
		configuration.timeoutIntervalForResource = 120
		return configuration
	}
}
