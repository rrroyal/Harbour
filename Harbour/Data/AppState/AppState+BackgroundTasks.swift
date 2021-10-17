//
//  AppState+BackgroundTasks.swift
//  Harbour
//
//  Created by royal on 17/10/2021.
//

import Foundation
import BackgroundTasks
import UserNotifications
import WidgetKit
import PortainerKit

extension AppState {
	enum BackgroundTask {
		static var refresh = "\(Bundle.main.mainBundleIdentifier).refresh"
	}
	
	public func scheduleBackgroundRefreshTask() {
		let task = BackgroundTask.refresh
		
		logger.info("(Background refresh) Scheduling background refresh task with identifier \"\(task)\"")
		
		let request = BGAppRefreshTaskRequest(identifier: task)
		
		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			logger.error("(Background refresh) Could not schedule app refresh: \(String(describing: error))")
		}
	}
	
	public func cancelBackgroundRefreshTask() {
		BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundTask.refresh)
	}
	
	public func handleBackgroundRefreshTask(task: BGAppRefreshTask) {
		logger.debug("(Background refresh) Handling background refresh for task \"\(task.identifier)\"")
		
		WidgetCenter.shared.reloadAllTimelines()
		Preferences.shared.lastBackgroundTaskDate = Date()
		scheduleBackgroundRefreshTask()

		Task {
			do {
				let savedState = Portainer.shared.containers.reduce(into: [:]) { $0[$1.id] = $1.state?.rawValue }
				let currentState = (try await Portainer.shared.getContainers()).reduce(into: [:]) { $0[$1.id] = $1.state?.rawValue }
				let differences = currentState.filter { savedState[$0.key] != $0.value }
				
				if savedState.count != currentState.count || !differences.isEmpty {
					logger.info("(Background refresh) savedState.count (\(savedState.count)) != currentState.count (\(currentState.count)) || differences.count (\(differences.count)) > 0!")
					
					let notificationID = "ContainerStatusNotification-\(Date().timeIntervalSinceReferenceDate)"
					let content = UNMutableNotificationContent()
					content.relevanceScore = 1
					content.interruptionLevel = .active
					content.sound = .default
					
					if differences.count == 1 {
						let container = Portainer.shared.containers.first(where: { $0.id == differences.first?.key })
						content.title = container?.displayName ?? container?.id ?? differences.first?.key ?? "Unknown container"
						content.body = container?.status ?? differences.first?.value ?? "unknown"
					} else {
						let containers = Portainer.shared.containers.filter({ differences.keys.contains($0.id) }).map({ $0.displayName ?? $0.id })
						content.title = "\(differences.count) containers changed!"
						content.body = ListFormatter.localizedString(byJoining: containers)
					}
					
					let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: nil)
					try await UNUserNotificationCenter.current().add(request)
				}
				
				task.setTaskCompleted(success: true)
			} catch {
				logger.error("(Background refresh) Error handling background refresh: \(String(describing: error))")
				task.setTaskCompleted(success: false)
			}
		}
	}
}
