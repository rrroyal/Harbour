//
//  AppDelegate.swift
//  Harbour
//
//  Created by royal on 19/12/2022.
//

import UIKit

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		return true
	}
}

// MARK: - AppDelegate+UIWindowSceneDelegate

extension AppDelegate: UIWindowSceneDelegate {
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
		sceneConfig.delegateClass = SceneDelegate.self
		return sceneConfig
	}
}
