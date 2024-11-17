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

		var body: some View {
			@Bindable var sceneDelegate = sceneDelegate

			TabView(selection: $sceneDelegate.activeTab) {
				Tab(value: .containers) {
//					NavigationSplitView {
//						ContainersView()
//					} detail: {
//						NavigationStack(path: $sceneDelegate.navigationState.containers) {
//							Text("ContainersView.NoContainerSelectedPlaceholder")
//								.foregroundStyle(.tertiary)
//						}
//					}
					NavigationStack(path: $sceneDelegate.navigationState.containers) {
						ContainersView()
							.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
								ContainerDetailsView(navigationItem: navigationItem)
									.equatable()
							}
					}
				} label: {
					Label {
						Text(ViewTab.containers.title)
					} icon: {
						ViewTab.containers.icon
					}
//					.environment(\.symbolVariants, sceneDelegate.activeTab == .containers ? .fill : .none)
				}

				Tab(value: .stacks) {
//					NavigationSplitView {
//						StacksView()
//					} detail: {
//						NavigationStack(path: $sceneDelegate.navigationState.stacks) {
//							Text("StacksView.NoStackSelectedPlaceholder")
//								.foregroundStyle(.tertiary)
//						}
//					}
					NavigationStack(path: $sceneDelegate.navigationState.stacks) {
						StacksView()
							.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
								StackDetailsView(navigationItem: navigationItem)
									.equatable()
							}
					}
				} label: {
					Label {
						Text(ViewTab.stacks.title)
					} icon: {
						ViewTab.stacks.icon
					}
//					.environment(\.symbolVariants, sceneDelegate.activeTab == .stacks ? .fill : .none)
				}
			}
		}
	}
}

// MARK: - Previews

#Preview("Empty") {
	ContentView.ViewForIOS()
		.withEnvironment()
		.environment(SceneDelegate())
}

#Preview("Mocked", traits: .modifier(PortainerStorePreviewModifier())) {
	ContentView.ViewForIOS()
		.withEnvironment()
		.environment(SceneDelegate())
}
