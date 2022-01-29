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
	private static let queryContainerID = "containerID"
	private static let pathOpen = "open"
	
	case openContainer(containerID: PortainerKit.Container.ID)
	
	public var url: URL? {
		var components = URLComponents()
		components.scheme = Self.scheme
		
		switch self {
			case .openContainer(let containerID):
				components.path = Self.pathOpen
				components.queryItems = [
					URLQueryItem(name: Self.queryContainerID, value: containerID)
				]
		}
		
		return components.url
	}
	
	public static func fromURL(_ url: URL) -> Self? {
		guard isValidURL(url) else { return nil }
		let components = URLComponents(string: url.absoluteString.lowercased())
		
		switch components?.path {
			case Self.pathOpen:
				guard let containerID = components?.queryItems?.first(where: { $0.name == Self.pathOpen })?.value else { return nil }
				return .openContainer(containerID: containerID)
			default:
				return nil
		}
	}
	
	public static func isValidURL(_ url: URL) -> Bool {
		return url.scheme?.lowercased() == scheme.lowercased()
	}
}
