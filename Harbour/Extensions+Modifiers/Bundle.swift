//
//  Bundle.swift
//  Harbour
//
//  Created by royal on 07/04/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import UIKit

extension Bundle {
	public var appIcon: UIImage? {
		if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
			let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
			let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
			let lastIcon = iconFiles.last {
			return UIImage(named: lastIcon)
		}
		return nil
	}
	
	public var appIcons: [String] {
		return ["Light", "Dark", "Dev"]
	}
	
	public var buildVersion: String {
		return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
	}
	
	public var buildNumber: String {
		return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
	}
}
