//
//  SceneDelegate+UIWindowSceneDelegate.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension SceneDelegate: UIWindowSceneDelegate {
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		#if targetEnvironment(macCatalyst)
		if let titlebar = windowScene.titlebar {
			titlebar.toolbarStyle = .unifiedCompact
			titlebar.titleVisibility = .hidden
			titlebar.toolbar?.isVisible = false
		}
		#endif
	}
}
#endif
