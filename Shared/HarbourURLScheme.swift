//
//  HarbourURLScheme.swift
//  Harbour
//
//  Created by royal on 17/01/2022.
//

import Foundation
import PortainerKit

enum HarbourURLScheme {
	private static let scheme = "harbour"

	case openContainer(containerID: PortainerKit.Container.ID)
	
	public var url: URL? {
		var components = URLComponents()
		components.scheme = Self.scheme
		
		switch self {
			case .openContainer(let containerID):
				components.path = Path.open
				components.queryItems = [
					URLQueryItem(name: Query.containerID, value: containerID)
				]
		}
		
		return components.url
	}
	
	public static func fromURL(_ url: URL) -> Self? {
		guard isValidURL(url) else { return nil }
		let components = URLComponents(string: url.absoluteString.lowercased())

		switch components?.path {
			case Path.open:
				guard let containerID = components?.queryItems?.first(where: { $0.name == Query.containerID })?.value else { return nil }
				return .openContainer(containerID: containerID)
			default:
				return nil
		}
	}
	
	public static func isValidURL(_ url: URL) -> Bool {
		return url.scheme?.lowercased() == scheme
	}

	enum Path {
		static let open = "open"
	}

	enum Query {
		static let containerID = "containerid"
	}
}
