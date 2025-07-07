//
//  ContentView+ViewForMacOS.swift
//  Harbour
//
//  Created by royal on 26/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - ContentView+ViewForMacOS

extension ContentView {
	struct ViewForMacOS: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@State private var columnVisibility: NavigationSplitViewVisibility = .all
		@ScaledMetric(relativeTo: .title2) private var sidebarWidth = 54

		var body: some View {
			NavigationSplitView(columnVisibility: $columnVisibility) {
				SidebarContent()
					.toolbar(removing: .sidebarToggle)
					.navigationSplitViewColumnWidth(sidebarWidth)
					.focusable(false)
			} content: {
				MainContent()
					.navigationSplitViewColumnWidth(min: 260, ideal: 260)
					.toolbar {
						ToolbarItem(placement: .navigation) {
							Button {
								columnVisibility = columnVisibility == .all ? .doubleColumn : .all
							} label: {
								Label("ContentView.ToggleSidebar", systemImage: "sidebar.left")
							}
						}
					}
			} detail: {
				DetailContent()
					.focusable(false)
			}
			.environment(sceneDelegate)
			.animation(.default, value: columnVisibility)
		}
	}
}

// MARK: - ContentView.ViewForMacOS+SidebarContent

private extension ContentView.ViewForMacOS {
	struct SidebarContent: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		private let padding: Double = 8

		var body: some View {
			VStack(spacing: 0) {
				ForEach(ViewTab.allCases, id: \.hashValue) { tab in
					Button {
						sceneDelegate.activeTab = tab
					} label: {
						tab.icon
							.accessibilityLabel(Text(tab.title))
							.padding(.vertical)
							.frame(maxWidth: .infinity)
					}
					.foregroundStyle(sceneDelegate.activeTab == tab ? .primary : .tertiary)
					.symbolVariant(sceneDelegate.activeTab == tab ? .fill : .none)
				}

				Spacer()

				SettingsLink {
					Image(systemName: SFSymbol.settings)
						.padding(.vertical)
						.frame(maxWidth: .infinity)
				}
				.foregroundStyle(.tertiary)
			}
			.buttonStyle(.customTransparent(includePadding: false))
			.font(.title2)
			.fontWeight(.medium)
			.padding(.bottom, padding)
			.padding(.horizontal, padding)
			.animation(.default, value: sceneDelegate.activeTab)
		}
	}
}

// MARK: - ContentView.ViewForMacOS+MainContent

private extension ContentView.ViewForMacOS {
	struct MainContent: View {
		@Environment(SceneDelegate.self) private var sceneDelegate

		var body: some View {
			Group {
				switch sceneDelegate.activeTab {
				case .containers:
					ContainersView()
						.navigationDestination(for: ContainerDetailsView.NavigationItem.self) { navigationItem in
							ContainerDetailsView(navigationItem: navigationItem)
						}
				case .stacks:
					StacksView()
						.navigationDestination(for: StackDetailsView.NavigationItem.self) { navigationItem in
							StackDetailsView(navigationItem: navigationItem)
						}
				}
			}
		}
	}
}

// MARK: - ContentView.ViewForMacOS+DetailContent

private extension ContentView.ViewForMacOS {
	struct DetailContent: View {
		@Environment(SceneDelegate.self) private var sceneDelegate

		var body: some View {
			@Bindable var sceneDelegate = sceneDelegate

			switch sceneDelegate.activeTab {
			case .containers:
				NavigationStack(path: $sceneDelegate.navigationState.containers) {
					Text("ContainersView.NoContainerSelectedPlaceholder")
						.foregroundStyle(.tertiary)
				}
			case .stacks:
				NavigationStack(path: $sceneDelegate.navigationState.stacks) {
					Text("StacksView.NoStackSelectedPlaceholder")
						.foregroundStyle(.tertiary)
				}
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContentView.ViewForMacOS()
}
