//
//  HarbourDeeplink.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - HarbourDeeplink

/// A struct containing the needed information about the deeplinking navigation.
struct HarbourDeeplink {
	let destination: Destination?
	let subdestination: [String]?

	init(destination: Destination? = nil, subdestination: [String]? = nil) {
		self.destination = destination
		self.subdestination = subdestination
	}
}

// MARK: - HarbourDeeplink+Destination

extension HarbourDeeplink {
	/// Root destination for the deeplinking navigation.
	enum Destination {
		/// Container details; navigates to ``ContainerDetailsView``.
		case containerDetails(id: Container.ID, displayName: String?, endpointID: Endpoint.ID?)

		/// Settings; opens the ``SettingsView`` sheet.
		case settings
	}
}

// MARK: - HarbourDeeplink+Static

extension HarbourDeeplink {
	/// URL scheme for this deeplink.
	static let scheme = "harbour"
}

// MARK: - HarbourDeeplink+init

extension HarbourDeeplink {
	init?(from url: URL) {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			// URL is malformed
			return nil
		}
		guard components.scheme?.lowercased() == Self.scheme.lowercased() else {
			// Scheme isn't ours; bail
			return nil
		}

		guard let host = components.host?.lowercased() else {
			self.destination = nil
			self.subdestination = nil
			return
		}

		let path = components.path.split(separator: "/")

		switch Host(rawValue: host) {
		case .containerDetails:
			guard let containerID = path.first else { return nil }

			let displayName = components.queryItems?.value(for: .name)
			let endpointID: Endpoint.ID? = if let endpointIDStr = components.queryItems?.value(for: .endpointID) {
				Int(endpointIDStr)
			} else {
				nil
			}

			self.destination = .containerDetails(id: String(containerID), displayName: displayName, endpointID: endpointID)

			let subdestination = path
				.dropFirst()
				.map { $0.lowercased() }
			self.subdestination = subdestination
		case .settings:
			self.destination = .settings
			self.subdestination = nil
		case .none:
			self.destination = nil
			self.subdestination = nil
		}
	}
}

// MARK: - HarbourDeeplink+url

extension HarbourDeeplink {
	/// `URL` created for this deeplink.
	var url: URL? {
		var components = URLComponents()
		components.scheme = Self.scheme

		guard let destination else {
			components.host = ""
			return components.url
		}

		components.host = Host(for: destination).rawValue

		switch destination {
		case .containerDetails(let id, let displayName, let endpointID):
			components.path = "/" + id

			components.queryItems = [
				.init(name: QueryKey.name.rawValue, value: displayName),
				.init(name: QueryKey.endpointID.rawValue, value: endpointID?.description ?? "")
			]
		case .settings:
			break
		}

		if let subdestination {
			components.path += "/" + subdestination.joined(separator: "/")
		}

		return components.url
	}
}

// MARK: - HarbourDeeplink+Host

private extension HarbourDeeplink {
	/// The `host` URL part, mirroring ``Destination``.
	enum Host: String {
		case containerDetails = "container-details"
		case settings = "settings"

		init(for destination: Destination) {
			switch destination {
			case .containerDetails:
				self = .containerDetails
			case .settings:
				self = .settings
			}
		}
	}
}

// MARK: - HarbourDeeplink+QueryKey

private extension HarbourDeeplink {
	/// Keys for the parameters of `query` URL part.
	enum QueryKey: String {
		case name = "n"
		case endpointID = "eid"
	}
}

// MARK: - [URLQueryItem]+value

private extension [URLQueryItem] {
	func value(for key: HarbourDeeplink.QueryKey) -> String? {
		first { $0.name.lowercased() == key.rawValue.lowercased() }?.value
	}
}
