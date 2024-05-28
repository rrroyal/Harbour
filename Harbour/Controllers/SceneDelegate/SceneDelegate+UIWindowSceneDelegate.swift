//
//  SceneDelegate+UIWindowSceneDelegate.swift
//  Harbour
//
//  Created by royal on 16/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

#if canImport(UIKit)
import CommonHaptics
import UIKit

// MARK: - SceneDelegate+UIWindowSceneDelegate

extension SceneDelegate: UIWindowSceneDelegate {
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		#if targetEnvironment(macCatalyst)
		if let windowScene = (scene as? UIWindowScene) {
			windowScene.titlebar?.titleVisibility = .hidden
			windowScene.titlebar?.toolbarStyle = .unifiedCompact
		}
		#endif

		if let shortcutItem = connectionOptions.shortcutItem {
			handleShortcutItem(shortcutItem)
		}
	}

	@MainActor
	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
		handleShortcutItem(shortcutItem)
	}
}

// MARK: - SceneDelegate+Private

private extension SceneDelegate {
	@discardableResult
	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
		switch shortcutItem.type {
		case HarbourShortcutItem.changeAppIcon:
			Haptics.generateIfEnabled(.sheetPresentation)
			isSettingsSheetPresented = true
			viewsToFocus.insert(SettingsView.ViewID.interfaceAppIcon)
		default:
			return false
		}

		return true
	}
}
#endif
