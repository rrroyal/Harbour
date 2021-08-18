//
//  UserDefaults+.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import Foundation

extension UserDefaults {
	enum Key {
		static let launchedBefore: String = "LaunchedBefore"

		static let endpointURL: String = "EndpointURL"
		
		static let enableHaptics: String = "EnableHaptics"
		static let displayContainerDismissedPrompt: String = "DisplayContainerDismissedPrompt"
	}
}
