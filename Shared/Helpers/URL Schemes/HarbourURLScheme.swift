//
//  HarbourURLScheme.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - HarbourURLScheme

enum HarbourURLScheme {
	static let scheme = "harbour"

	case containerDetails(id: Container.ID, displayName: String?, endpointID: Endpoint.ID?)
}

// MARK: - HarbourURLScheme+Host

extension HarbourURLScheme {
	enum Host {
		static let containerDetails = "containerDetails"
	}
}

// MARK: - HarbourURLScheme+QueryKey

extension HarbourURLScheme {
	enum QueryKey {
		static let containerID = "containerID"
		static let containerName = "containerName"
		static let endpointID = "endpointID"
	}
}

// MARK: - HarbourURLScheme+url

extension HarbourURLScheme {
	var url: URL? {
		var components = URLComponents()
		components.scheme = Self.scheme

		switch self {
		case .containerDetails(let id, let displayName, let endpointID):
			components.host = Host.containerDetails
			components.queryItems = [
				URLQueryItem(name: QueryKey.containerID, value: id),
				URLQueryItem(name: QueryKey.containerName, value: displayName),
				URLQueryItem(name: QueryKey.endpointID, value: endpointID?.description ?? "")
			]
		}

		return components.url
	}
}

// MARK: - HarbourURLScheme+fromURL

extension HarbourURLScheme {
	static func fromURL(_ url: URL) -> Self? {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			return nil
		}
		guard components.scheme?.lowercased() == Self.scheme.lowercased() else {
			return nil
		}

		switch components.host?.lowercased() {
		case Host.containerDetails.lowercased():
			guard let containerID = components.queryItems?.first(where: { $0.name.lowercased() == QueryKey.containerID.lowercased() })?.value else { return nil }
			let displayName = components.queryItems?.first(where: { $0.name.lowercased() == QueryKey.containerName.lowercased() })?.value

			let endpointID: Endpoint.ID?
			if let endpointIDStr = components.queryItems?.first(where: { $0.name.lowercased() == QueryKey.endpointID.lowercased() })?.value {
				endpointID = Int(endpointIDStr)
			} else {
				endpointID = nil
			}
			return .containerDetails(id: containerID, displayName: displayName, endpointID: endpointID)
		default:
			return nil
		}
	}
}
