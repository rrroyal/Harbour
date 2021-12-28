//
//  Keychain+Errors.swift
//  Keychain
//
//  Created by royal on 10/06/2021.
//

import Foundation

public extension Keychain {
	enum KeychainError: Error {
		case encodingFailed
		case decodingFailed
	}
	
	struct SecError: Error, CustomStringConvertible {
		public let status: OSStatus
		
		public var description: String {
			"\(SecCopyErrorMessageString(self.status, nil) as String? ?? "Unknown error") (\(self.status))"
		}
		
		internal init(_ status: OSStatus) {
			self.status = status
		}
	}
}
