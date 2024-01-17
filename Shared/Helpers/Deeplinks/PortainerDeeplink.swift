//
//  PortainerDeeplink.swift
//  Harbour
//
//  Created by royal on 30/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

struct PortainerDeeplink {
	let baseURL: URL

	init?(baseURL: URL?) {
		guard let baseURL else { return nil }
		self.baseURL = baseURL
	}

	func containerURL(containerID: Container.ID, endpointID: Endpoint.ID?) -> URL? {
		// <address>/#!/<endpointID>/docker/containers/<containerID>
		guard let endpointID else { return nil }

		guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
			return nil
		}

		urlComponents.path = "/"

		let fragmentParts = [
			"!",
			"\(endpointID)",
			"docker",
			"containers",
			containerID
		]
		urlComponents.fragment = fragmentParts.joined(separator: "/")

		return urlComponents.url
	}
}
