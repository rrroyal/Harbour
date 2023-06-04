//
//  IntentError.swift
//  HarbourIntents
//
//  Created by royal on 04/10/2022.
//

import Foundation

// MARK: - IntentError

enum IntentError: Error {
	/// Intent doesn't have configuration selected.
	case noConfigurationSelected

	/// No value found for selected configuration.
	case noValueForConfiguration
}

// MARK: - IntentError+LocalizedError

extension IntentError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .noConfigurationSelected:
			return Localizable.Errors.Intents.noConfigurationSelected
		case .noValueForConfiguration:
			return Localizable.Errors.Intents.noValueForConfiguration
		}
	}
}
