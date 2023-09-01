//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import IndicatorsKit
import PortainerKit
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - HarbourApp

@main
struct HarbourApp: App {
	#if os(iOS)
	@UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
	#elseif os(macOS)
	@NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
	#endif

	@Environment(\.scenePhase) private var scenePhase: ScenePhase
	@StateObject private var portainerStore: PortainerStore
	@StateObject private var preferences: Preferences = .shared
	@State private var appState: AppState = .shared

	init() {
		let portainerStore = PortainerStore.shared
		portainerStore.loadStoredContainersIfNeeded()
		self._portainerStore = .init(wrappedValue: portainerStore)
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(portainerStore)
				.environmentObject(preferences)
				.environment(appState)
				.environment(\.portainerServerURL, portainerStore.serverURL)
				.environment(\.portainerSelectedEndpointID, portainerStore.selectedEndpoint?.id)
				.environment(\.cvUseGrid, preferences.cvUseGrid)
				.environment(\.ikEnableHaptics, preferences.enableHaptics)
		}
		.defaultAppStorage(Preferences.userDefaults)
		.modelContainer(for: [StoredContainer.self])
		.onChange(of: scenePhase) {
			onScenePhaseChange(from: $0, to: $1)
		}
		.onChange(of: portainerStore.containers) {
			onContainersChange(from: $0, to: $1)
		}
		#if os(iOS)
		.backgroundTask(.appRefresh(HarbourBackgroundTaskIdentifier.backgroundRefresh), action: appState.handleBackgroundRefresh)
		#endif
	}
}

// MARK: - HarbourApp+Actions

private extension HarbourApp {
	@MainActor
	func onScenePhaseChange(from previousScenePhase: ScenePhase, to newScenePhase: ScenePhase) {
		switch newScenePhase {
		case .background:
			#if os(iOS)
			appState.scheduleBackgroundRefresh()
			#endif
		case .inactive:
			break
		case .active:
			if portainerStore.isSetup || portainerStore.setupTask != nil {
				portainerStore.refresh()
			}
		@unknown default:
			break
		}
	}

	func onContainersChange(from previousContainers: [Container], to newContainers: [Container]) {
		Task.detached {
			WidgetCenter.shared.reloadAllTimelines()
		}

		// TODO: Index in spotlight (https://www.donnywals.com/adding-your-apps-content-to-spotlight)
	}
}
