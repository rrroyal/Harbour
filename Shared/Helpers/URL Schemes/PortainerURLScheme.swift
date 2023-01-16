//
//  PortainerURLScheme.swift
//  Harbour
//
//  Created by royal on 30/09/2022.
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

		let addressString = address.absoluteString

		let pathParts = [
			"#!",
			endpointID.description,
			"docker",
			"containers",
			containerID
		]
		let path = pathParts.joined(separator: "/")

		let urlString = "\(addressString)/\(path)"
		return URL(string: urlString)
	}
}
