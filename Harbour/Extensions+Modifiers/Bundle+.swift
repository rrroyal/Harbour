//
//  Bundle+.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation

extension Bundle {
	public var buildVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
	}
	
	public var buildNumber: String {
		Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
	}
}
