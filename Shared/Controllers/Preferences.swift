//
//  Preferences.shared.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import SwiftUI

final class Preferences: ObservableObject {
	public static let shared: Preferences = Preferences()

	@AppStorage(Key.finishedSetup.rawValue, store: .standard) public var finishedSetup: Bool = false
	
	@AppStorage(Key.selectedServer.rawValue, store: .group) public var selectedServer: URL?
	@AppStorage(Key.selectedEndpointID.rawValue, store: .group) public var selectedEndpointID: Int?

	@AppStorage(Key.enableBackgroundRefresh.rawValue, store: .group) public var enableBackgroundRefresh: Bool = false
	@AppStorage(Key.autoRefreshInterval.rawValue, store: .standard) public var autoRefreshInterval: Double = 0
	
	@AppStorage(Key.enableHaptics.rawValue, store: .standard) public var enableHaptics: Bool = true
	
	@AppStorage(Key.clUseGridView.rawValue, store: .standard) public var clUseGridView: Bool = false
	@AppStorage(Key.clUseColumns.rawValue, store: .standard) public var clUseColumns: Bool = true
	@AppStorage(Key.clUseColoredContainerCells.rawValue, store: .group) public var clUseColoredContainerCells: Bool = false
	
	@AppStorage(Key.persistAttachedContainer.rawValue, store: .standard) public var persistAttachedContainer: Bool = true
	
	#if DEBUG
	var lastBackgroundTaskDate: Date? {
		get {
			let time = Self.ud.double(forKey: Key.lastBackgroundTaskDate.rawValue)
			if time > 0 {
				return Date(timeIntervalSinceReferenceDate: time)
			} else {
				return nil
			}
		}
		set { Self.ud.set(newValue?.timeIntervalSinceReferenceDate, forKey: Key.lastBackgroundTaskDate.rawValue) }
	}
	#endif
	
	public static let ud: UserDefaults = .group

	private init() {}
}

extension Preferences {
	enum Key: String, CaseIterable {
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
	}
}

extension UserDefaults {
	static var group: UserDefaults = UserDefaults(suiteName: "group.\(Bundle.main.mainBundleIdentifier)")!
}
