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
	@Environment(\.scenePhase) private var scenePhase: ScenePhase
	@StateObject private var portainerStore: PortainerStore
	@StateObject private var preferences: Preferences = .shared
	@State private var appState: AppState = .shared
	private let modelContainer: ModelContainer

	init() {
		do {
			self.modelContainer = try ModelContainer(for: StoredContainer.self)

			let portainerStore = PortainerStore.shared
			portainerStore.modelContext = modelContainer.mainContext
			portainerStore.setupInitially()
			self._portainerStore = .init(wrappedValue: portainerStore)

			Task {
				if portainerStore.isSetup {
					portainerStore.refresh()
				}
			}
		} catch {
			fatalError("Failed to create ModelContainer!")
		}
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.withEnvironment(
					appState: appState,
					preferences: preferences,
					portainerStore: portainerStore
				)
		}
		.onChange(of: scenePhase) {
			onScenePhaseChange(from: $0, to: $1)
		}
		.onChange(of: portainerStore.containers) {
			onContainersChange(from: $0, to: $1)
		}
		#if os(iOS)
		.backgroundTask(.appRefresh(HarbourBackgroundTaskIdentifier.backgroundRefresh), action: appState.handleBackgroundRefresh)
		#endif
		.commands {
			CommandGroup(before: .newItem) {
				Button {
					portainerStore.refresh()
				} label: {
					Label("Generic.Refresh", systemImage: SFSymbol.reload)
				}
				.keyboardShortcut("r", modifiers: .command)

				Divider()
			}
		}
		#if os(macOS)
		.windowToolbarStyle(.unified)
		#endif

		#if os(macOS)
		Settings {
			SettingsView()
				.withEnvironment(
					appState: appState,
					preferences: preferences,
					portainerStore: portainerStore
				)
		}
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
			if portainerStore.isSetup && !(portainerStore.endpointsTask != nil || portainerStore.containersTask != nil) {
				portainerStore.refresh()
			}
		@unknown default:
			break
		}
	}

	func onContainersChange(from previousContainers: [Container], to newContainers: [Container]) {
		Task.detached {
			WidgetCenter.shared.reloadAllTimelines()
			await NSUserActivity.deleteAllSavedUserActivities()
		}

		#if os(iOS)
		Task.detached { @MainActor in
			UIApplication.shared.shortcutItems = nil
		}
		#endif

		// TODO: Index in spotlight (https://www.donnywals.com/adding-your-apps-content-to-spotlight)
	}
}
