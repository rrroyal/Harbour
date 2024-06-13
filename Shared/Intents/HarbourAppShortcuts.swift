//
//  HarbourAppShortcuts.swift
//  Harbour
//
//  Created by royal on 11/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import AppIntents

// swiftlint:disable lower_acl_than_parent

struct HarbourAppShortcuts: AppShortcutsProvider {
	@AppShortcutsBuilder
	public static var appShortcuts: [AppShortcut] {
		AppShortcut(
			intent: ContainerActionIntent(),
			phrases: [
				"Execute container action"
			],
			shortTitle: "ContainerActionIntent.Title",
			systemImageName: "bolt"
		)

//		AppShortcut(
//			intent: ContainerStatusIntent(),
//			phrases: [
//				"Get container status in \(.applicationName)",
//				"Check container in \(.applicationName)"
//			],
//			shortTitle: "ContainerStatusIntent.Title",
//			systemImageName: "questionmark"
//		)
	}

	public static var shortcutTileColor: ShortcutTileColor { .purple }
}

// swiftlint:enable lower_acl_than_parent
