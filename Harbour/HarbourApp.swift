//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import IndicatorsKit
import PortainerKit
import SwiftData
import SwiftUI
import TipKit

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
//				#if os(macOS)
//				.containerBackground(.thickMaterial, for: .window)
//				#endif
				.withEnvironment(
					appState: appState,
					preferences: preferences,
					portainerStore: portainerStore
				)
				.task {
					do {
						try Tips.configure([
							// swiftlint:disable:next force_unwrapping
							.datastoreLocation(.groupContainer(identifier: "group.\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!)")),
							.displayFrequency(.immediate)
						])
					} catch {
						appState.logger.warning("Failed to configure Tips: \(error.localizedDescription, privacy: .public)")
					}
				}
		}
		.onChange(of: portainerStore.containers, appState.onContainersChange)
		.onChange(of: portainerStore.stacks, appState.onStacksChange)
		#if os(iOS)
		.backgroundTask(.appRefresh(BackgroundHelper.TaskIdentifier.backgroundRefresh), action: BackgroundHelper.handleBackgroundRefresh)
		#endif
		.commands {
			PortainerCommands(portainerStore: portainerStore)
		}
		#if os(macOS)
		.windowStyle(.hiddenTitleBar)
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
				.scrollDismissesKeyboard(.interactively)
		}
		.modelContainer(for: ModelContainer.allModelTypes)
		#endif
	}
}

// MARK: - HarbourApp+PortainerCommands

extension HarbourApp {
	struct PortainerCommands: Commands {
		let portainerStore: PortainerStore

		var body: some Commands {
			CommandMenu("CommandMenu.Portainer") {
				Button {
					portainerStore.refreshEndpoints()
					portainerStore.refreshContainers()
					portainerStore.refreshStacks()
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
							.tag(endpoint)
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
