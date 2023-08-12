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
	#if os(iOS)
	@UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
	#elseif os(macOS)
	@NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
	#endif

	@Environment(\.scenePhase) private var scenePhase: ScenePhase
	@StateObject private var appState: AppState = .shared
	@StateObject private var portainerStore: PortainerStore = .shared
	@StateObject private var preferences: Preferences = .shared

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
		#if os(iOS)
		.backgroundTask(.appRefresh(HarbourBackgroundTaskIdentifier.backgroundRefresh), action: appState.handleBackgroundRefresh)
		#endif
	}
}

// MARK: - HarbourApp+Actions

private extension HarbourApp {
	@MainActor
	func onScenePhaseChange(previous previousScenePhase: ScenePhase, new newScenePhase: ScenePhase) {
		switch newScenePhase {
		case .background:
			#if os(iOS)
			appState.scheduleBackgroundRefresh()
			#endif
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
