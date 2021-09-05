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

	@AppStorage(Preferences.Key.launchedBefore.rawValue, store: .group) public var launchedBefore: Bool = false
	@AppStorage(Preferences.Key.enableHaptics.rawValue, store: .group) public var enableHaptics: Bool = true
	@AppStorage(Preferences.Key.persistAttachedContainer.rawValue, store: .group) public var persistAttachedContainer: Bool = true
	@AppStorage(Preferences.Key.displayContainerDismissedPrompt.rawValue, store: .group) public var displayContainerDismissedPrompt: Bool = true
	@AppStorage(Preferences.Key.autoRefreshInterval.rawValue, store: .group) public var autoRefreshInterval: Double = 0
	@AppStorage(Preferences.Key.endpointURL.rawValue, store: .group) public var endpointURL: String?
	
	public let ud: UserDefaults = .group

	private init() {}
}

extension Preferences {
	enum Key: String, CaseIterable {
		case launchedBefore = "LaunchedBefore"
		
		case endpointURL = "EndpointURL"
		
		case persistAttachedContainer = "PersistAttachedContainer"
		case displayContainerDismissedPrompt = "DisplayContainerDismissedPrompt"
		case enableHaptics = "EnableHaptics"
		
		case autoRefreshInterval = "AutoRefreshInterval"
	}
}

extension UserDefaults {
	static var group: UserDefaults = UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier!)")!
}
