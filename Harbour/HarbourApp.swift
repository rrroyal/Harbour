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
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	#elseif os(macOS)
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	#endif
	@StateObject private var portainerStore: PortainerStore
	@StateObject private var preferences: Preferences = .shared
	@State private var appState: AppState = .shared

	init() {
		let portainerStore = PortainerStore.shared
		portainerStore.setupInitially()
		self._portainerStore = .init(wrappedValue: portainerStore)
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.scrollDismissesKeyboard(.interactively)
				.withEnvironment(
					appState: appState,
					preferences: preferences,
					portainerStore: portainerStore
				)
		}
		.onChange(of: portainerStore.containers, onContainersChange)
		#if os(iOS)
		.backgroundTask(.appRefresh(BackgroundHelper.TaskIdentifier.backgroundRefresh), action: BackgroundHelper.handleBackgroundRefresh)
		#endif
		.commands {
			PortainerCommandMenu(portainerStore: portainerStore)
		}
		#if os(macOS)
//		.windowStyle(.hiddenTitleBar)
		.windowToolbarStyle(.unifiedCompact(showsTitle: false))
		#endif
		.modelContainer(for: ModelContainer.allModelTypes)

		#if os(macOS)
		Settings {
			SettingsView()
				.withEnvironment(
					appState: appState,
					preferences: preferences,
					portainerStore: portainerStore
				)
				#if os(macOS)
				.sheetMinimumFrame()
				#endif
				.scrollDismissesKeyboard(.interactively)
		}
		.modelContainer(for: ModelContainer.allModelTypes)
		#endif
	}
}

// MARK: - HarbourApp+Actions

private extension HarbourApp {
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
	}
}

// MARK: - HarbourApp+Commands

private extension HarbourApp {
	struct PortainerCommandMenu: Commands {
		var portainerStore: PortainerStore

		@MainActor
		var body: some Commands {
			CommandMenu("CommandMenu.Portainer") {
				Button {
					portainerStore.refresh()
				} label: {
					Label("Generic.Refresh", systemImage: SFSymbol.reload)
				}
				.keyboardShortcut("r", modifiers: .command)
				.disabled(!portainerStore.isSetup)

				Divider()

				let selectedEndpointBinding = Binding<Endpoint?>(
					get: { portainerStore.selectedEndpoint },
					set: { portainerStore.setSelectedEndpoint($0) }
				)
				Picker(selection: selectedEndpointBinding) {
					ForEach(portainerStore.endpoints) { endpoint in
						Text(endpoint.name ?? endpoint.id.description)
							.tag(endpoint as Endpoint?)
					}
				} label: {
					Text("CommandMenu.Portainer.ActiveEndpoint")
					if let selectedEndpoint = selectedEndpointBinding.wrappedValue {
						Text(selectedEndpoint.name ?? selectedEndpoint.id.description)
							.foregroundStyle(.secondary)
					}
				}
				.disabled(portainerStore.endpoints.isEmpty)
			}
		}
	}
}
