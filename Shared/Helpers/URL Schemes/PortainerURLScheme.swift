//
//  PortainerURLScheme.swift
//  Harbour
//
//  Created by royal on 30/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

struct PortainerURLScheme {
	let address: URL

	init?(address: URL?) {
		guard let address else { return nil }
		self.address = address
	}

	func containerURL(containerID: Container.ID, endpointID: Endpoint.ID?) -> URL? {
		// <address.absoluteString>/#!/<endpointID>/docker/containers/<containerID>
		guard let endpointID else { return nil }

		guard var urlComponents = URLComponents(url: address, resolvingAgainstBaseURL: true) else {
			return nil
		}

		let pathParts = [
			"#!",
			"\(endpointID)",
			"docker",
			"containers",
			containerID
		]
		let path = "/" + pathParts.joined(separator: "/")
		urlComponents.path = path

		return urlComponents.url
	}
}
