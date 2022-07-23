//
//  Keychain+Errors.swift
//  Keychain
//
//  Created by royal on 10/06/2021.
//

import Foundation

public extension Keychain {
	enum KeychainError: LocalizedError {
		case encodingFailed
		case decodingFailed

		public var errorDescription: String? {
			switch self {
				case .encodingFailed: return "Encoding failed"
				case .decodingFailed: return "Decoding failed"
			}
		}
	}

	struct SecError: LocalizedError {
		public let status: OSStatus

		public var errorDescription: String? {
			"\(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error") (\(self.status))"
		}

		internal init(_ status: OSStatus) {
			self.status = status
		}
	}
}
