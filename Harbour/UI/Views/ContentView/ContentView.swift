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
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.scenePhase) private var scenePhase

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate
		TabView(selection: $sceneDelegate.activeTab) {
			ContainersView()
				.tag(ViewTab.containers)
				.tabItem {
					Label(ViewTab.containers.label, systemImage: ViewTab.containers.icon)
//						.environment(\.symbolVariants, sceneDelegate.activeTab == .containers ? .fill : .none)
				}
				.environment(\.navigationPath, sceneDelegate.navigationPathContainers)

			StacksView()
				.tag(ViewTab.stacks)
				.tabItem {
					Label(ViewTab.stacks.label, systemImage: ViewTab.stacks.icon)
//						.environment(\.symbolVariants, sceneDelegate.activeTab == .stacks ? .fill : .none)
				}
				.environment(\.navigationPath, sceneDelegate.navigationPathStacks)
		}
		.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
			SettingsView()
				.environment(sceneDelegate)
		}
		.sheet(isPresented: $sceneDelegate.isLandingSheetPresented) {
			sceneDelegate.onLandingDismissed()
		} content: {
			LandingView()
		}
		.alert(
			sceneDelegate.activeAlert?.title ?? "",
			isPresented: .constant(sceneDelegate.activeAlert != nil),
			presenting: sceneDelegate.activeAlert
		) { _ in
			Button("Generic.OK") { }
		} message: { details in
			if let message = details.message {
				Text(message)
			}
		}
		.indicatorOverlay(model: sceneDelegate.indicators)
		.animation(.easeInOut, value: portainerStore.isSetup)
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails, perform: sceneDelegate.onContinueUserActivity)
		.onContinueUserActivity(HarbourUserActivityIdentifier.stackDetails, perform: sceneDelegate.onContinueUserActivity)
		.onChange(of: appState.notificationsToHandle, sceneDelegate.onNotificationsToHandleChange)
		.onChange(of: scenePhase, sceneDelegate.onScenePhaseChange)
		.environment(\.errorHandler, .init(handleError))
		.environment(\.presentIndicator, sceneDelegate.presentIndicator)
		.withNavigation(handler: sceneDelegate)
	}
}

// MARK: - ContentView+Actions

private extension ContentView {
	func handleError(_ error: Error, _debugInfo: String = ._debugInfo()) {
		sceneDelegate.handleError(error, _debugInfo: _debugInfo)
	}
}

// MARK: - Previews

#Preview {
	ContentView()
		.withEnvironment(appState: .shared)
}
