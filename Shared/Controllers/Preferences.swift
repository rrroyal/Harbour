//
//  Preferences.shared.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

final class Preferences: ObservableObject {
	public static let shared: Preferences = Preferences()

	@AppStorage(Keys.finishedSetup.rawValue, store: .standard) public var finishedSetup: Bool = false
	@AppStorage(Keys.autoRefreshInterval.rawValue, store: .standard) public var autoRefreshInterval: Double = 0
	@AppStorage(Keys.enableHaptics.rawValue, store: .standard) public var enableHaptics: Bool = true
	@AppStorage(Keys.persistAttachedContainer.rawValue, store: .standard) public var persistAttachedContainer: Bool = true
	@AppStorage(Keys.enableDebugLogging.rawValue, store: .standard) public var enableDebugLogging: Bool = false
	@AppStorage(Keys.clUseGridView.rawValue, store: .standard) public var clUseGridView: Bool = false
	@AppStorage(Keys.clUseColumns.rawValue, store: .standard) public var clUseColumns: Bool = true

	@AppStorage(Keys.selectedServer.rawValue, store: .group) public var selectedServer: URL?
	@AppStorage(Keys.selectedEndpointID.rawValue, store: .group) public var selectedEndpointID: Int?
	@AppStorage(Keys.enableBackgroundRefresh.rawValue, store: .group) public var enableBackgroundRefresh: Bool = false
	@AppStorage(Keys.clUseColoredContainerCells.rawValue, store: .group) public var clUseColoredContainerCells: Bool = false

	#if DEBUG
	var lastBackgroundTaskDate: Date? {
		get {
			let time = Self.ud.double(forKey: Keys.lastBackgroundTaskDate.rawValue)
			if time > 0 {
				return Date(timeIntervalSinceReferenceDate: time)
			} else {
				return nil
			}
		}
		set { Self.ud.set(newValue?.timeIntervalSinceReferenceDate, forKey: Keys.lastBackgroundTaskDate.rawValue) }
	}
	#endif
	
	public static let ud: UserDefaults = .group

	private init() {}
}

extension Preferences {
	enum Keys: String, CaseIterable {
		case finishedSetup = "FinishedSetup"
		
		case selectedServer = "SelectedServer"
		case selectedEndpointID = "SelectedEndpointID"
		
		case enableBackgroundRefresh = "EnableBackgroundRefresh"
		case autoRefreshInterval = "AutoRefreshInterval"
		
		case enableHaptics = "EnableHaptics"
		
		case clUseGridView = "CLUseGridView"
		case clUseColumns = "CLUseColumns"
		case clUseColoredContainerCells = "CLUseColoredContainerCells"
		
		case persistAttachedContainer = "PersistAttachedContainer"
		
		#if DEBUG
		case lastBackgroundTaskDate = "LastBackgroundTaskDate"
		#endif

		case enableDebugLogging = "EnableDebugLogging"
	}
}

extension UserDefaults {
	static let group = UserDefaults(suiteName: "group.\(Bundle.main.mainBundleIdentifier)")!
}
