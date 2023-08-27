//
//  GenericError.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// MARK: - GenericError

enum GenericError: Error {
	case invalidURL
}

// MARK: - GenericError+LocalizableError

extension GenericError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .invalidURL:
			String(localized: "Error.Generic.InvalidURL")
		}
	}
}
