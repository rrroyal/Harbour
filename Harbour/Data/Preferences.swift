//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import SwiftUI

class Preferences: ObservableObject {
	public static let shared: Preferences = Preferences()

	@AppStorage(Preferences.Key.finishedSetup.rawValue, store: .group) public var finishedSetup: Bool = false
	@AppStorage(Preferences.Key.hasSavedCredentials.rawValue, store: .group) public var hasSavedCredentials: Bool = false
	
	@AppStorage(Preferences.Key.endpointURL.rawValue, store: .group) public var endpointURL: String?
	@AppStorage(Preferences.Key.selectedEndpointID.rawValue, store: .group) public var selectedEndpointID: Int?

	@AppStorage(Preferences.Key.enableBackgroundRefresh.rawValue, store: .group) public var enableBackgroundRefresh: Bool = false
	@AppStorage(Preferences.Key.autoRefreshInterval.rawValue, store: .group) public var autoRefreshInterval: Double = 0
	
	@AppStorage(Preferences.Key.enableHaptics.rawValue, store: .group) public var enableHaptics: Bool = true
	@AppStorage(Preferences.Key.useGridView.rawValue, store: .group) public var useGridView: Bool = false
	@AppStorage(Preferences.Key.useColoredContainerCells.rawValue, store: .group) public var useColoredContainerCells: Bool = false
	@AppStorage(Preferences.Key.persistAttachedContainer.rawValue, store: .group) public var persistAttachedContainer: Bool = true
	@AppStorage(Preferences.Key.displayContainerDismissedPrompt.rawValue, store: .group) public var displayContainerDismissedPrompt: Bool = true

	#if DEBUG
	var lastBackgroundTaskDate: Date? {
		get {
			let time = Self.ud.double(forKey: Preferences.Key.lastBackgroundTaskDate.rawValue)
			if time > 0 {
				return Date(timeIntervalSinceReferenceDate: time)
			} else {
				return nil
			}
		}
		set { Self.ud.set(newValue?.timeIntervalSinceReferenceDate, forKey: Preferences.Key.lastBackgroundTaskDate.rawValue) }
	}
	#endif
	
	public static let ud: UserDefaults = .group

	private init() {}
}

extension Preferences {
	enum Key: String, CaseIterable {
		case finishedSetup = "FinishedSetup"
		case hasSavedCredentials = "HasSavedCredentials"
		
		case endpointURL = "EndpointURL"
		case selectedEndpointID = "SelectedEndpointID"
		
		case enableBackgroundRefresh = "EnableBackgroundRefresh"
		case autoRefreshInterval = "AutoRefreshInterval"
		
		case enableHaptics = "EnableHaptics"
		case useGridView = "UseGridView"
		case useColoredContainerCells = "UseColoredContainerCells"
		case persistAttachedContainer = "PersistAttachedContainer"
		case displayContainerDismissedPrompt = "DisplayContainerDismissedPrompt"
		
		#if DEBUG
		case lastBackgroundTaskDate = "LastBackgroundTaskDate"
		#endif
	}
}

extension UserDefaults {
	static var group: UserDefaults = UserDefaults(suiteName: "\(Bundle.main.appIdentifierPrefix)group.\(Bundle.main.mainBundleIdentifier)")!
}
