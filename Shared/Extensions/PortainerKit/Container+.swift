//
//  Container+.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import CommonFoundation
import Foundation
import PortainerKit

// MARK: - Container+displayName

extension Container {
	var displayName: Container.Name? {
		guard let firstName = names?.first else { return nil }
		return firstName.starts(with: "/") ? String(firstName.dropFirst()) : firstName
	}
}

// MARK: - Container+readableStatus

extension Container {
	static func readableStatus(status: String?, state: ContainerState?) -> String {
		if let status {
			return "\(status) (\(state.description))"
		}

		return state.description
	}
}

// MARK: - Container+stack

extension Container {
	var stack: String? {
		labels?.first(where: { $0.key == Portainer.Label.stack })?.value
	}
}

// MARK: - [Container]+sorted

extension [Container] {
	func sorted() -> Self {
		sorted { ($0.displayName ?? "", $0.id) < ($1.displayName ?? "", $1.id) }
	}
}

// MARK: - [Container]+filtered

extension [Container] {
	func filtered(_ query: String) -> Self {
		if query.isReallyEmpty { return self }
		return filter {
			$0.names?.contains(where: { $0.localizedCaseInsensitiveContains(query) }) ?? false ||
			$0.id.localizedCaseInsensitiveContains(query)
//			$0.stack?.localizedCaseInsensitiveContains(query) ?? false
		}
	}
}
