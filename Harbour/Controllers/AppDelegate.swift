//
//  AppDelegate.swift
//  Harbour
//
//  Created by royal on 17/10/2021.
//

import Foundation
import UIKit
import BackgroundTasks
import PortainerKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
		
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		#if DEBUG
		let defaults: [String: Any] = [
			"_UIConstraintBasedLayoutLogUnsatisfiable": false
		]
		UserDefaults.standard.register(defaults: defaults)
		#endif

		Preferences.shared.enableDebugLogging = false
		
		BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTasks.BackgroundTask.refresh, using: nil) { task in
			BackgroundTasks.scheduleBackgroundRefreshTask()
			BackgroundTasks.handleBackgroundRefreshTask(task: task as? BGAppRefreshTask)
		}
				
		return true
	}
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
		sceneConfiguration.delegateClass = SceneDelegate.self

		return sceneConfiguration
	}
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
		#warning("TODO: Handle UIApplicationShortcutItem")
		return true
	}
}
