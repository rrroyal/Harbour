//
//  URLSessionConfiguration+harbourBackground.swift
//  Harbour
//
//  Created by royal on 01/11/2022.
//

import Foundation

extension URLSessionConfiguration {
//	private static let harbourBackgroundIdentifier = "\(Bundle.main.mainBundleIdentifier).BackgroundURLSession"

	/// URLSessionConfiguration for background tasks.
	static var harbourBackground: URLSessionConfiguration {
//		let configuration = URLSessionConfiguration.background(withIdentifier: Self.harbourBackgroundIdentifier)
		let configuration = URLSessionConfiguration.default
//		configuration.allowsConstrainedNetworkAccess = true
//		configuration.allowsCellularAccess = true
//		configuration.allowsExpensiveNetworkAccess = true
//		configuration.isDiscretionary = false
//		configuration.shouldUseExtendedBackgroundIdleMode = true
		configuration.timeoutIntervalForRequest = 5
		configuration.timeoutIntervalForResource = 5
		return configuration
	}
}
