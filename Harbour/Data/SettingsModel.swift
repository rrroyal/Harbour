//
//  SettingsModel.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON

/// Model containing user settings data
class SettingsModel: ObservableObject {
	private var ud = UserDefaults.standard
	
	@Published public var updatesAvailable: Bool = false
	
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
	
	public func checkForUpdates() {
		let currentVersion: String = Bundle.main.buildVersion
		let repoURL: URL = URL(string: "https://api.github.com/repos/rrroyal/Harbour/releases/latest")!
		
		// Check latest release
		print("[*] Checking latest release on GitHub (Local version: \(currentVersion))...")
		AF.request(repoURL, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
			switch response.result {
			case .success(_):
				if let responseValue = response.value {
					let json = JSON(responseValue)
					
					if (json["tag_name"].stringValue.dropFirst() > currentVersion && !json["draft"].boolValue && json["target_commitish"].stringValue == "master") {
						print("[!] New release available: \(json["tag_name"]).")
						self.updatesAvailable = true
					} else {
						print("[*] Already on latest version.")
					}
				}
				break
			case .failure(let error):
				print("[!] Couldn't check latest release: \(error)")
				break
			}
		}
	}
	
	init() {
		self.checkForUpdates()
	}
}
