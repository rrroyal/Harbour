//
//  ContentView+ViewForIOS.swift
//  Harbour
//
//  Created by royal on 26/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

#if os(iOS)

import SwiftUI

// MARK: - ContentView+ViewForIOS

extension ContentView {
	struct ViewForIOS: View {
		@Environment(SceneDelegate.self) private var sceneDelegate

		var body: some View {
			@Bindable var sceneDelegate = sceneDelegate

			TabView(selection: $sceneDelegate.activeTab) {
				NavigationWrapped(navigationPath: $sceneDelegate.navigationPathContainers) {
					ContainersView()
				} placeholderContent: {
					Text("ContainersView.NoContainerSelectedPlaceholder")
						.foregroundStyle(.tertiary)
				}
				.tag(ViewTab.containers)
				.tabItem {
					Label {
						Text(ViewTab.containers.label)
					} icon: {
						ViewTab.containers.icon
					}
					.environment(\.symbolVariants, sceneDelegate.activeTab == .containers ? .fill : .none)
				}
				.environment(\.navigationPath, sceneDelegate.navigationPathContainers)

				NavigationWrapped(navigationPath: $sceneDelegate.navigationPathStacks) {
					StacksView()
				} placeholderContent: {
					Text("StacksView.NoStackSelectedPlaceholder")
						.foregroundStyle(.tertiary)
				}
				.tag(ViewTab.stacks)
				.tabItem {
					Label {
						Text(ViewTab.stacks.label)
					} icon: {
						ViewTab.stacks.icon
					}
					.environment(\.symbolVariants, sceneDelegate.activeTab == .stacks ? .fill : .none)
				}
				.environment(\.navigationPath, sceneDelegate.navigationPathStacks)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContentView.ViewForIOS()
}

#endif
