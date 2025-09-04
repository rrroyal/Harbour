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
	@EnvironmentObject private var portainerStore: PortainerStore
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
		#if os(iOS)
		.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
			SettingsView()
		}
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
		.environment(sceneDelegate)
		.environment(\.errorHandler, .init(sceneDelegate.handleError))
		.environment(\.presentIndicator, .init(sceneDelegate.presentIndicator))
		.withNavigation(handler: sceneDelegate)
	}
}

// MARK: - Previews

#Preview {
	ContentView()
		.withEnvironment()
		.environment(SceneDelegate())
}
