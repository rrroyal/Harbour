//
//  HarbourDeeplink.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - HarbourDeeplink

/// An enum that coordinates the deeplinking navigation.
enum HarbourDeeplink {
	/// Container details; navigates to ``ContainerDetailsView``.
	case containerDetails(id: Container.ID, displayName: String?, endpointID: Endpoint.ID?)

	/// Settings; opens the ``SettingsView`` sheet.
	case settings
}

// MARK: - HarbourDeeplink+Static

extension HarbourDeeplink {
	/// URL scheme for this deeplink.
	static let scheme = "harbour"

	/// Empty deeplink URL, navigating just to the app.
	static let appURL: URL = {
		var components = URLComponents()
		components.scheme = Self.scheme
		components.host = ""
		// swiftlint:disable:next force_unwrapping
		return components.url!
	}()
}

// MARK: - HarbourDeeplink+init

extension HarbourDeeplink {
	/// Initializes the navigation scheme based on the supplied `url`.
	/// - Parameter url: `URL` to parse
	init?(url: URL) {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			// URL is malformed
			return nil
		}
		guard components.scheme?.lowercased() == Self.scheme.lowercased() else {
			// Scheme isn't ours; bail
			return nil
		}
		guard let host = components.host?.lowercased() else {
			// There's no host, so we don't know what to do; bail
			return nil
		}

		switch Host(rawValue: host) {
		case .containerDetails:
			guard let containerID = components.queryItems?.value(for: .id) else { return nil }
			let displayName = components.queryItems?.value(for: .name)

			let endpointID: Endpoint.ID? = if let endpointIDStr = components.queryItems?.value(for: .endpointID) {
				Int(endpointIDStr)
			} else {
				nil
			}
			self = .containerDetails(id: containerID, displayName: displayName, endpointID: endpointID)
		default:
			return nil
		}
	}
}

// MARK: - HarbourDeeplink+url

extension HarbourDeeplink {
	/// The actual `URL` created for this scheme.
	var url: URL? {
		var components = URLComponents()
		components.scheme = Self.scheme
		components.host = Host(for: self).rawValue

		switch self {
		case .containerDetails(let id, let displayName, let endpointID):
			components.queryItems = [
				.init(name: QueryKey.id.rawValue, value: id),
				.init(name: QueryKey.name.rawValue, value: displayName),
				.init(name: QueryKey.endpointID.rawValue, value: endpointID?.description ?? "")
			]
		case .settings:
			break
		}

		return components.url
	}
}

// MARK: - HarbourDeeplink+Host

private extension HarbourDeeplink {
	/// The `host` URL part, mirroring ``HarbourDeeplink`` cases.
	enum Host: String {
		case containerDetails = "container-details"
		case settings = "settings"

		init(for deeplink: HarbourDeeplink) {
			switch deeplink {
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
		case id = "id"
		case name = "n"
		case endpointID = "eid"
	}
}

// MARK: - [URLQueryItem]+value

private extension [URLQueryItem] {
	func value(for key: HarbourDeeplink.QueryKey) -> String? {
		first(where: { $0.name.lowercased() == key.rawValue.lowercased() })?.value
	}
}
