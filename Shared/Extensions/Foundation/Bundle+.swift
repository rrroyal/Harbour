//
//  Bundle+.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation

public extension Bundle {
	var buildVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
	}

	var buildNumber: String {
		Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
	}

	var mainBundleIdentifier: String {
		Bundle.main.infoDictionary?["HBMainBundleIdentifier"] as? String ?? "xyz.shameful.Harbour"
	}

	var appIdentifierPrefix: String? {
		Bundle.main.infoDictionary?["HBAppIdentifierPrefix"] as? String
	}

	var groupIdentifier: String {
		"\(Bundle.main.appIdentifierPrefix ?? "")group.\(Bundle.main.mainBundleIdentifier)"
	}
}
