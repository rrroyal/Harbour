//
//  GenericError.swift
//  Harbour
//
//  Created by royal on 06/05/2022.
//

import Foundation

enum GenericError: LocalizedError {
	case invalidURL

	var localizedDescription: String? {
		switch self {
			case .invalidURL:
				return Localization.Error.invalidURL
		}
	}
}
