//
//  AppDelegate.swift
//  Harbour
//
//  Created by royal on 17/10/2021.
//

import Foundation
import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
		let defaults: [String: Any] = [
			"_UIConstraintBasedLayoutLogUnsatisfiable": false
		]
		UserDefaults.standard.register(defaults: defaults)
#endif
		
		BGTaskScheduler.shared.register(forTaskWithIdentifier: AppState.BackgroundTask.refresh, using: nil) { task in
			AppState.shared.scheduleBackgroundRefreshTask()
			AppState.shared.handleBackgroundRefreshTask(task: task as! BGAppRefreshTask)
		}
				
		return true
	}
}
