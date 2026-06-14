//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CoreSpotlight
import IndicatorsKit
import Navigation
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
	@Environment(AppState.self) private var appState
	#if os(iOS)
	@Environment(SceneDelegate.self) private var sceneDelegate
	#elseif os(macOS)
	@State private var sceneDelegate = SceneDelegate()
	#endif
	@Environment(PortainerStore.self) private var portainerStore
	@EnvironmentObject private var preferences: Preferences
	@Environment(\.scenePhase) private var scenePhase

	var body: some View {
		@Bindable var sceneDelegate = sceneDelegate

		Group {
			#if os(iOS)
			ViewForIOS()
			#elseif os(macOS)
			ViewForMacOS()
			#endif
		}
		.animation(.default, value: portainerStore.isSetup)
		#if os(iOS)
		.indicatorOverlay(model: sceneDelegate.indicators, alignment: .top, insets: .init(top: 4, leading: 0, bottom: 0, trailing: 0))
		#elseif os(macOS)
		.indicatorOverlay(model: sceneDelegate.indicators, alignment: .topTrailing, insets: .init(top: 8, leading: 0, bottom: 0, trailing: 0))
		#endif
		.sheet(isPresented: $sceneDelegate.isLandingSheetPresented) {
			sceneDelegate.onLandingDismissed()
		} content: {
			LandingView()
				#if os(macOS)
				.sheetMinimumFrame()
				#endif
		}
		.sheet(isPresented: $sceneDelegate.isContainerChangesSheetPresented) {
			NavigationStack {
				ContainerChangeView(changes: appState.lastContainerChanges ?? [])
					.addingCloseButton()
			}
//			.presentationDetents([.medium, .large])
			#if os(macOS)
			.sheetMinimumFrame()
			#endif
		}
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails) {
			sceneDelegate.onContinueUserActivity($0)
		}
		.onContinueUserActivity(HarbourUserActivityIdentifier.stackDetails) {
			sceneDelegate.onContinueUserActivity($0)
		}
		.onContinueUserActivity(CSSearchableItemActionType) {
			sceneDelegate.onSpotlightUserActivity($0)
		}
		.onChange(of: appState.notificationsToHandle) {
			sceneDelegate.onNotificationsToHandleChange(before: $0, after: $1)
		}
		.onChange(of: scenePhase, sceneDelegate.onScenePhaseChange)
		.task(id: ObjectIdentifier(portainerStore)) {
			sceneDelegate.configure(
				portainerStore: portainerStore,
				appState: appState,
				preferences: preferences
			)
		}
		.environment(sceneDelegate)
		.environment(\.errorHandler, .init(sceneDelegate.handleError))
		.environment(\.presentIndicator, .init(sceneDelegate.presentIndicator))
		.withNavigation(handler: sceneDelegate)
	}
}

// MARK: - Previews

#Preview {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	let appState = AppState(portainerStore: portainerStore)
	ContentView()
		.withEnvironment(appState: appState, preferences: preferences, portainerStore: portainerStore)
		.environment(SceneDelegate())
}
