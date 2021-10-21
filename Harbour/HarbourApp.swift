//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import SwiftUI
import Indicators

@main
struct HarbourApp: App {
	@Environment(\.scenePhase) var scenePhase
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onChange(of: scenePhase, perform: onScenePhaseChange)
				.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
				.defaultAppStorage(.group)
				.environmentObject(appState)
				.environmentObject(portainer)
				.environmentObject(preferences)
				.environment(\.useContainerGridView, preferences.useGridView)
				.environment(\.useColoredContainerCells, preferences.useColoredContainerCells)
		}
	}
	
	private func onScenePhaseChange(_ scenePhase: ScenePhase) {
		switch scenePhase {
			case .active:
				Task {
					try? await portainer.getContainers()
				}
			case .background:
				if preferences.enableBackgroundRefresh {
					appState.scheduleBackgroundRefreshTask()
				}
			default:
				break
		}
	}
	
	private func onDeviceDidShake(_: Notification) {
		if portainer.attachedContainer != nil {
			appState.showAttachedContainer()
		}
	}
}
