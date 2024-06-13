//
//  Keychain.KeychainError+LocalizedError.swift
//  Harbour
//
//  Created by royal on 01/09/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import KeychainKit

extension Keychain.KeychainError: @retroactive LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .encodingFailed: String(localized: "Keychain.KeychainError.EncodingFailed")
		case .decodingFailed: String(localized: "Keychain.KeychainError.DecodingFailed")
		}
	}
}
