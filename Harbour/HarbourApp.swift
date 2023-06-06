//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - HarbourApp

@main
struct HarbourApp: App {
	@UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
	@Environment(\.scenePhase) private var scenePhase: ScenePhase
	@StateObject var appState: AppState = .shared
	@StateObject var portainerStore: PortainerStore = .shared
	@StateObject var preferences: Preferences = .shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
				.environmentObject(portainerStore)
				.environmentObject(preferences)
				.environment(\.portainerServerURL, portainerStore.serverURL)
				.environment(\.portainerSelectedEndpointID, portainerStore.selectedEndpoint?.id)
				.environment(\.cvUseGrid, preferences.cvUseGrid)
		}
		.defaultAppStorage(Preferences.userDefaults)
		.onChange(of: scenePhase) {
			onScenePhaseChange(previous: $0, new: $1)
		}
		.backgroundTask(.appRefresh(HarbourBackgroundTaskIdentifier.backgroundRefresh), action: appState.handleBackgroundRefresh)
	}
}

// MARK: - HarbourApp+Actions

private extension HarbourApp {
	func onScenePhaseChange(previous previousScenePhase: ScenePhase, new newScenePhase: ScenePhase) {
		switch newScenePhase {
		case .background:
			appState.scheduleBackgroundRefresh()
		case .inactive:
			break
		case .active:
			if portainerStore.isSetup {
				portainerStore.refresh()
			}
		@unknown default:
			break
		}
	}
}
