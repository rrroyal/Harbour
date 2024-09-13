//
//  Deeplink.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

// swiftlint:disable:next convenience_type
public struct Deeplink {
	/// URL scheme for this deeplink.
	public static let scheme = "harbour"

	/// URL with only our scheme.
	public static var appURL: URL? {
		var components = URLComponents()
		components.scheme = Self.scheme
		components.host = ""
		return components.url
	}

	public static func destination(from url: URL) -> Deeplink.Destination? {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			// URL is malformed
			return nil
		}
		guard components.scheme?.localizedCaseInsensitiveCompare(Self.scheme) == .orderedSame else {
			// Scheme isn't ours; bail
			return nil
		}

		guard let host = components.host?.lowercased() else {
			// There's no host, so we don't know what to do
			return nil
		}

		switch Deeplink.Host(rawValue: host) {
		case .containers:
			return ContainersDestination(from: components)
		case .containerDetails:
			return ContainerDetailsDestination(from: components)
		case .stacks:
			return StacksDestination(from: components)
		case .stackDetails:
			return StackDetailsDestination(from: components)
		case .settings:
			return SettingsDestination(from: components)
		case .none:
			return nil
		}
	}
}

// MARK: - Deeplink+QueryKey

internal extension Deeplink {
	/// Keys for the parameters of `query` URL part.
	enum QueryKey: String {
		case name = "n"
		case endpointID = "eid"
		case persistentID = "pid"
	}
}

// MARK: - [URLQueryItem]+value

internal extension [URLQueryItem] {
	func value(for key: Deeplink.QueryKey) -> String? {
		first { $0.name.localizedCaseInsensitiveCompare(key.rawValue) == .orderedSame }?.value
	}
}
