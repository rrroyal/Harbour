//
//  IntentError.swift
//  HarbourIntents
//
//  Created by royal on 04/10/2022.
//

import Foundation

enum IntentError: LocalizedError {

	/// Intent doesn't have configuration selected.
	case noConfigurationSelected

	/// No value found for selected configuration.
	case noValueForConfiguration

}
