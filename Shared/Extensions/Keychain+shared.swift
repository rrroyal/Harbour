//
//  Keychain+shared.swift
//  Harbour
//
//  Created by royal on 25/05/2023.
//

import Foundation
import KeychainKit

extension Keychain {
	// swiftlint:disable:next force_unwrapping
	static let shared = Keychain(accessGroup: Bundle.main.groupIdentifier!)
}
