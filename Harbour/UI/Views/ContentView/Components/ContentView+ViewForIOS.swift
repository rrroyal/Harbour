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
					NavigationSplitView {
						ContainersView()
					} detail: {
						NavigationStack(path: $sceneDelegate.navigationState.containers) {
							Text("ContainersView.NoContainerSelectedPlaceholder")
								.foregroundStyle(.tertiary)
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
					NavigationSplitView {
						StacksView()
					} detail: {
						NavigationStack(path: $sceneDelegate.navigationState.stacks) {
							Text("StacksView.NoStackSelectedPlaceholder")
								.foregroundStyle(.tertiary)
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

#Preview {
	ContentView.ViewForIOS()
}
