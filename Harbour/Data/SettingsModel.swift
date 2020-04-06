//
//  SettingsModel.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import Foundation
import Combine

/// Model containing user settings data
class SettingsModel: ObservableObject {
	private var ud = UserDefaults.standard
	
	public var loggedIn: Bool {
		get { return ud.bool(forKey: "loggedIn") }
		set (value) { if (ud.bool(forKey: "loggedIn") != value) { ud.set(value, forKey: "loggedIn") } }
	}
	
	public var hapticFeedback: Bool {
		get { return ud.bool(forKey: "hapticFeedback") }
		set (value) { if (ud.bool(forKey: "hapticFeedback") != value) { ud.set(value, forKey: "hapticFeedback") } }
	}
	
	public var enableDrawer: Bool {
		get { return ud.bool(forKey: "enableDrawer") }
		set (value) { if (ud.bool(forKey: "enableDrawer") != value) { ud.set(value, forKey: "enableDrawer") } }
	}
	
	public var useFullScreenDashboard: Bool {
		get { return ud.bool(forKey: "useFullScreenDashboard") }
		set (value) { if (ud.bool(forKey: "useFullScreenDashboard") != value) { ud.set(value, forKey: "useFullScreenDashboard") } }
	}
	
	public var automaticRefresh: Bool {
		get { return ud.bool(forKey: "automaticRefresh") }
		set (value) { if (ud.bool(forKey: "automaticRefresh") != value) { ud.set(value, forKey: "automaticRefresh") } }
	}
	
	public var endpointURL: String {
		get { return ud.string(forKey: "endpointURL") ?? "" }
		set (value) { if (ud.string(forKey: "endpointURL") != value) { ud.set(value, forKey: "endpointURL") } }
	}
	
	public var refreshInterval: Double {
		get { return ud.double(forKey: "refreshInterval") }
		set (value) { if (ud.double(forKey: "refreshInterval") != value) { ud.set(value, forKey: "refreshInterval") } }
	}
	
	public func resetSettings() {
		print("[!] Resetting settings!")
		ud.set(false, forKey: "launchedBefore")
	}
}
