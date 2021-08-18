//
//  Preferences.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import Foundation
import SwiftUI

class Preferences: ObservableObject {
	public static let shared: Preferences = Preferences()

	@AppStorage(UserDefaults.Key.launchedBefore) public var launchedBefore: Bool = false
	@AppStorage(UserDefaults.Key.enableHaptics) public var enableHaptics: Bool = true
	@AppStorage(UserDefaults.Key.displayContainerDismissedPrompt) public var displayContainerDismissedPrompt: Bool = true
	
	public let ud: UserDefaults = UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier!)") ?? UserDefaults.standard

	private init() {}
}
