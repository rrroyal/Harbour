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

	@AppStorage(Preferences.Key.finishedSetup.rawValue, store: .group) public var finishedSetup: Bool = false
	
	@AppStorage(Preferences.Key.endpointURL.rawValue, store: .group) public var endpointURL: String?
	@AppStorage(Preferences.Key.autoRefreshInterval.rawValue, store: .group) public var autoRefreshInterval: Double = 0
	
	@AppStorage(Preferences.Key.enableHaptics.rawValue, store: .group) public var enableHaptics: Bool = true
	@AppStorage(Preferences.Key.useGridView.rawValue, store: .group) public var useGridView: Bool = false
	@AppStorage(Preferences.Key.persistAttachedContainer.rawValue, store: .group) public var persistAttachedContainer: Bool = true
	@AppStorage(Preferences.Key.displayContainerDismissedPrompt.rawValue, store: .group) public var displayContainerDismissedPrompt: Bool = true

	public let ud: UserDefaults = .group

	private init() {}
}

extension Preferences {
	enum Key: String, CaseIterable {
		case finishedSetup = "FinishedSetup"
		
		case endpointURL = "EndpointURL"
		case autoRefreshInterval = "AutoRefreshInterval"
		
		case enableHaptics = "EnableHaptics"
		case useGridView = "UseGridView"
		case persistAttachedContainer = "PersistAttachedContainer"
		case displayContainerDismissedPrompt = "DisplayContainerDismissedPrompt"
	}
}

extension UserDefaults {
	static var group: UserDefaults = UserDefaults(suiteName: "\(Bundle.main.appIdentifierPrefix)group.\(Bundle.main.bundleIdentifier!)")!
}
