//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import SwiftUI
import Indicators
import PortainerKit

@main
/// Main entry point for Harbour
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
				.environmentObject(appState)
				.environmentObject(portainer)
				.environmentObject(preferences)
				.environment(\.useContainerGridView, preferences.clUseGridView)
				.environment(\.useColoredContainerCells, preferences.clUseColoredContainerCells)
		}
	}
	
	private func onScenePhaseChange(_ scenePhase: ScenePhase) {
		switch scenePhase {
			case .active:
				if (portainer.isSetup || portainer.hasSavedCredentials) && portainer.serverURL != nil {
					Task {
						try await portainer.getEndpoints()
						if portainer.selectedEndpointID != nil {
							try await portainer.getContainers()
						}
					}
				}
			case .background:
				if preferences.enableBackgroundRefresh {
					BackgroundTasks.scheduleBackgroundRefreshTask()
				}
			default:
				break
		}
	}
}
