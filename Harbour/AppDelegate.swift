//
//  AppDelegate.swift
//  Harbour
//
//  Created by unitears on 27/07/2021.
//

import UIKit
import LoadingIndicator

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		
		let sceneConfiguration = UISceneConfiguration(name: "Scene", sessionRole: connectingSceneSession.role)
		sceneConfiguration.delegateClass = SceneDelegate.self
		
		return sceneConfiguration
	}
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
}
