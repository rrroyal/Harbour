//
//  AppDelegate+UIApplicationDelegate.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension AppDelegate: UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		// Setup UserNotificationCenter
		UNUserNotificationCenter.current().delegate = self

		return true
	}
}
#endif
