//
//  HarbourAppShortcuts.swift
//  Harbour
//
//  Created by royal on 11/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import AppIntents

struct HarbourAppShortcuts: AppShortcutsProvider {
	@AppShortcutsBuilder
	static var appShortcuts: [AppShortcut] {
		AppShortcut(
			intent: ContainerActionIntent(),
			phrases: [
				"Execute container action in \(.applicationName)",
				"Ask \(.applicationName) to \(\.$containerAction) a container"
			],
			shortTitle: "ContainerActionIntent.Title",
			systemImageName: "cube.transparent.fill"
		)

		AppShortcut(
			intent: ContainerStatusIntent(),
			phrases: [
				"Get container status in \(.applicationName)",
				"Check container in \(.applicationName)",
				"Ask \(.applicationName) what's the status of \(\.$container)"
			],
			shortTitle: "ContainerStatusIntent.Title",
			systemImageName: "cube.fill"
		)

//		AppShortcut(
//			intent: StackActionIntent(),
//			phrases: [
//				"Set stack state in \(.applicationName)"
//			],
//			shortTitle: "StackActionIntent.Title",
//			systemImageName: "square.stack.3d.up"
//		)

//		AppShortcut(
//			intent: StackStatusIntent(),
//			phrases: [
//				"Get stack status in \(.applicationName)",
//				"Check stack in \(.applicationName)"
//			],
//			shortTitle: "StackStatusIntent.Title",
//			systemImageName: "square.stack.3d.up"
//		)
	}

	static var shortcutTileColor: ShortcutTileColor { .purple }
}
