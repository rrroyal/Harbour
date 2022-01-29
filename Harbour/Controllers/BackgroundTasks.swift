//
//  BackgroundTasks.swift
//  Harbour
//
//  Created by royal on 22/01/2022.
//

import Foundation
import BackgroundTasks
import os.log
import UserNotifications
import WidgetKit
import PortainerKit

struct BackgroundTasks {
	internal static let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BackgroundTasks")

	public static func scheduleBackgroundRefreshTask() {
		let task = BackgroundTask.refresh
		
		logger.info("(Background refresh) Scheduling background refresh task with identifier \"\(task, privacy: .public)\" [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
		let request = BGAppRefreshTaskRequest(identifier: task)
		
		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			logger.error("(Background refresh) Could not schedule app refresh: \(String(describing: error), privacy: .public) [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		}
	}
	
	public static func cancelBackgroundRefreshTask() {
		BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundTask.refresh)
	}
	
	public static func handleBackgroundRefreshTask(task: BGAppRefreshTask?, old: [PortainerKit.Container]? = nil, new: [PortainerKit.Container]? = nil) {
		guard Preferences.shared.enableBackgroundRefresh else { return }
		
		logger.notice("(Background refresh) Handling background refresh for task \"\(task?.identifier ?? "<none>", privacy: .public)\" [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
		
#if DEBUG
		Preferences.shared.lastBackgroundTaskDate = Date()
#endif
		
		Task {
			do {
				let savedContainers: [PortainerKit.Container]
				if let old = old {
					savedContainers = old
				} else {
					savedContainers = await Portainer.shared.containers
				}
				
				// ID: state
				let savedState: [String: PortainerKit.ContainerStatus] = savedContainers.reduce(into: [:], reduceContainerStates)
				
				let newContainers: [PortainerKit.Container]
				if let new = new {
					newContainers = new
				} else {
					newContainers = try await Portainer.shared.getContainers()
				}
				
				let newState: [String: PortainerKit.ContainerStatus] = newContainers.reduce(into: [:], reduceContainerStates)
				let differences = newState.filter { savedState[$0.key] != $0.value }
				
				if !differences.isEmpty {
					logger.info("(Background refresh) differences.count (\(differences.count, privacy: .public)) > 0! [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
					
					let notificationID = "ContainerStatusNotification-\(Date().timeIntervalSinceReferenceDate)"
					let content = UNMutableNotificationContent()
					content.interruptionLevel = .active
					content.sound = .default
					
					if differences.count == 1 {
						let container = newContainers.first(where: { $0.id == differences.first?.key })
						content.title = container?.displayName ?? container?.id ?? differences.first?.key ?? "Unknown container"
						content.body = container?.status ?? differences.first?.value.rawValue ?? "unknown"
						content.relevanceScore = 1
					} else if differences.count > 1 {
						let containerStrings = newContainers
							.filter { differences.keys.contains($0.id) }
							.map { "\($0.displayName ?? $0.id) (\($0.state?.rawValue ?? "unknown"))" }
						
						content.title = "\(containerStrings.count) containers changed!"
						content.body = ListFormatter.localizedString(byJoining: containerStrings)
						content.relevanceScore = 1 + (Double(differences.count) * 0.1)
					} else {
						return
					}
					
					let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: nil)
					try await UNUserNotificationCenter.current().add(request)
				}
				
				task?.setTaskCompleted(success: true)
			} catch {
				logger.error("(Background refresh) Error handling background refresh: \(String(describing: error), privacy: .public) [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
				task?.setTaskCompleted(success: false)
			}
			
			if task != nil {
				WidgetCenter.shared.reloadAllTimelines()
			}
		}
	}
	
	private static func reduceContainerStates(_ result: inout [String: PortainerKit.ContainerStatus], _ container: PortainerKit.Container) {
		result[container.id] = container.state
	}
}

extension BackgroundTasks {
	enum BackgroundTask {
		static var refresh = "\(Bundle.main.bundleIdentifier!).BackgroundRefreshTask"
	}
}
