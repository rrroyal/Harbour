//
//  Container+.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import Foundation
import PortainerKit

// MARK: - Container+displayName

extension Container {
	var displayName: String? {
		guard let firstName = names?.first else { return nil }
		return firstName.starts(with: "/") ? String(firstName.dropFirst()) : firstName
	}
}

// MARK: - Container+stack

extension Container {
	var stack: String? {
		labels?.first(where: { $0.key.lowercased() == Portainer.Label.stack.lowercased() })?.value
	}

	var associationID: String? {
		labels?.first(where: { $0.key.lowercased() == Portainer.Label.associationID.lowercased() })?.value
	}
}

// MARK: - Container+exitCode

extension Container {
	var exitCode: Int? {
		guard let status else { return nil }

		let regex = #/Exited \((\d*)\).*/#
		guard let firstMatch = status.firstMatch(of: regex) else { return nil }
		let str = firstMatch.output.1
		return Int(str)
	}
}

// MARK: - Container+isSame

extension Container {
	func isSame(as other: Self) -> Bool {
		self.id == other.id || (self.associationID != nil && self.associationID == other.associationID) || (self.image == other.image && self.names == other.names)
	}
}

// MARK: - [Container]+sorted

extension [Container] {
	func sorted() -> Self {
		sorted { ($0.displayName ?? "", $0.id) < ($1.displayName ?? "", $1.id) }
	}
}

// MARK: - [Container]+filter

extension [Container] {
	func filter(_ query: String, includingStacks: Bool = false) -> Self {
		if query.isReallyEmpty { return self }
		return filter {
			$0.names?.contains(where: { $0.localizedCaseInsensitiveContains(query) }) ?? false ||
			$0.id.localizedCaseInsensitiveContains(query) ||
			(includingStacks ? ($0.stack?.localizedCaseInsensitiveContains(query) ?? false) : false)
		}
	}
}
