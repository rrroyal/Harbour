//
//  ContentView+ViewForIOS.swift
//  Harbour
//
//  Created by royal on 26/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - ContentView+ViewForIOS

extension ContentView {
	struct ViewForIOS: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@Environment(PortainerStore.self) private var portainerStore
		@Environment(AppState.self) private var appState
		@EnvironmentObject private var preferences: Preferences

		var body: some View {
			@Bindable var sceneDelegate = sceneDelegate

			TabView(selection: $sceneDelegate.activeTab) {
				Tab(value: .containers) {
					NavigationSplitView {
						ContainersView(portainerStore: portainerStore, preferences: preferences)
							.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
								ContainerDetailsView(navigationItem: navigationItem, portainerStore: portainerStore)
							}
					} detail: {
						NavigationStack(path: $sceneDelegate.navigationState.containers) {
							if let selectedItem = sceneDelegate.selectedContainerNavigationItem {
								ContainerDetailsView(navigationItem: selectedItem, portainerStore: portainerStore)
							} else {
								Text("ContainersView.NoContainerSelectedPlaceholder")
									.foregroundStyle(.tertiary)
							}
						}
						.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
							ContainerDetailsView(navigationItem: navigationItem, portainerStore: portainerStore)
						}
					}
				} label: {
					Label {
						Text(ViewTab.containers.title)
					} icon: {
						ViewTab.containers.icon
					}
				}

				Tab(value: .stacks) {
					NavigationSplitView {
						StacksView(portainerStore: portainerStore, preferences: preferences)
							.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
								StackDetailsView(navigationItem: navigationItem, portainerStore: portainerStore)
							}
					} detail: {
						NavigationStack(path: $sceneDelegate.navigationState.stacks) {
							if let selectedItem = sceneDelegate.selectedStackNavigationItem {
								StackDetailsView(navigationItem: selectedItem, portainerStore: portainerStore)
							} else {
								Text("StacksView.NoStackSelectedPlaceholder")
									.foregroundStyle(.tertiary)
							}
						}
						.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
							StackDetailsView(navigationItem: navigationItem, portainerStore: portainerStore)
						}
					}
				} label: {
					Label {
						Text(ViewTab.stacks.title)
					} icon: {
						ViewTab.stacks.icon
					}
				}
			}
			.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
				SettingsView(portainerStore: portainerStore, appState: appState)
//					.navigationTransition(.zoom(sourceID: SettingsView.id, in: namespace))
			}
			.onChange(of: sceneDelegate.selectedContainerNavigationItem) { _, new in
				// Clear deeper navigation when user actively selects a new container.
				// Guard against nil to avoid wiping paths set by deeplink navigation,
				// since deeplinks set selection→nil then separately populate the path.
				if new != nil {
					sceneDelegate.navigationState.containers = NavigationPath()
				}
			}
			.onChange(of: sceneDelegate.selectedStackNavigationItem) { _, new in
				if new != nil {
					sceneDelegate.navigationState.stacks = NavigationPath()
				}
			}
		}
	}
}

// MARK: - Previews

#Preview("Empty") {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	let appState = AppState(portainerStore: portainerStore)
	ContentView.ViewForIOS()
		.withEnvironment(appState: appState, preferences: preferences, portainerStore: portainerStore)
		.environment(SceneDelegate())
}

#Preview("Mocked", traits: .modifier(PortainerStorePreviewModifier())) {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	let appState = AppState(portainerStore: portainerStore)
	ContentView.ViewForIOS()
		.withEnvironment(appState: appState, preferences: preferences, portainerStore: portainerStore)
		.environment(SceneDelegate())
}
