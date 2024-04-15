//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import IndicatorsKit
import Navigation
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(AppState.self) private var appState
	@Environment(\.scenePhase) private var scenePhase
	@State private var sceneState = SceneState()

	var body: some View {
		TabView(selection: $sceneState.activeTab) {
			ContainersView()
				.tag(ViewTab.containers)
				.tabItem {
					Label(ViewTab.containers.label, systemImage: ViewTab.containers.icon)
						.labelsHidden()
				}
				.environment(\.navigationPath, sceneState.navigationPathContainers)

			StacksView()
				.tag(ViewTab.stacks)
				.tabItem {
					Label(ViewTab.stacks.label, systemImage: ViewTab.stacks.icon)
				}
				.environment(\.navigationPath, sceneState.navigationPathStacks)
		}
		.sheet(isPresented: $sceneState.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $sceneState.isLandingSheetPresented) {
			sceneState.onLandingDismissed()
		} content: {
			LandingView()
		}
		.alert(
			sceneState.activeAlert?.title ?? "",
			isPresented: .constant(sceneState.activeAlert != nil),
			presenting: sceneState.activeAlert
		) { _ in
			Button("Generic.OK") { }
		} message: { details in
			if let message = details.message {
				Text(message)
			}
		}
		.indicatorOverlay(model: sceneState.indicators)
		.animation(.easeInOut, value: portainerStore.isSetup)
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails, perform: sceneState.onContinueContainerDetailsActivity)
		.onChange(of: appState.notificationsToHandle, sceneState.onNotificationsToHandleChange)
		.onChange(of: scenePhase, sceneState.onScenePhaseChange)
		.environment(sceneState)
		.environment(\.errorHandler, .init(handleError))
		.environment(\.presentIndicator, sceneState.presentIndicator)
		.withNavigation(handler: sceneState)
	}
}

// MARK: - ContentView+Actions

private extension ContentView {
	func handleError(_ error: Error, _debugInfo: String = ._debugInfo()) {
		sceneState.handleError(error, _debugInfo: _debugInfo)
	}
}

// MARK: - ContentView+ViewTab

extension ContentView {
	enum ViewTab {
		case containers
		case stacks

		var label: String {
			switch self {
			case .containers:
				String(localized: "ContainersView.Title")
			case .stacks:
				String(localized: "StacksView.Title")
			}
		}

		var icon: String {
			switch self {
			case .containers:
				SFSymbol.container
			case .stacks:
				SFSymbol.stack
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContentView()
		.withEnvironment(appState: .shared)
}
