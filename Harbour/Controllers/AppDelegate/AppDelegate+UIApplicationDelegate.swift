//
//  AppDelegate+UIApplicationDelegate.swift
//  Harbour
//
//  Created by royal on 22/06/2023.
//

#if canImport(UIKit)
import UIKit

// MARK: - AppDelegate+UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
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
#endif
