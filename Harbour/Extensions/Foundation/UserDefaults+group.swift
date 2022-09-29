//
//  UserDefaults+group.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation

extension UserDefaults {
	// swiftlint:disable:next force_unwrapping
	static let group = UserDefaults(suiteName: Bundle.main.groupIdentifier)!
}
