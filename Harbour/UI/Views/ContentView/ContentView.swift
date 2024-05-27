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
		.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
			SettingsView()
				.environment(sceneDelegate)
		}
		.sheet(isPresented: $sceneDelegate.isLandingSheetPresented) {
			sceneDelegate.onLandingDismissed()
		} content: {
			LandingView()
				#if os(macOS)
				.sheetMinimumFrame()
				#endif
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
		#if os(iOS)
		.indicatorOverlay(model: sceneDelegate.indicators, alignment: .top, insets: .init(top: 4, leading: 0, bottom: 0, trailing: 0))
		#elseif os(macOS)
		.indicatorOverlay(model: sceneDelegate.indicators, alignment: .topTrailing, insets: .init(top: 8, leading: 0, bottom: 0, trailing: 0))
		#endif
		.animation(.easeInOut, value: portainerStore.isSetup)
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails, perform: sceneDelegate.onContinueUserActivity)
		.onContinueUserActivity(HarbourUserActivityIdentifier.stackDetails, perform: sceneDelegate.onContinueUserActivity)
		.onChange(of: appState.notificationsToHandle, sceneDelegate.onNotificationsToHandleChange)
		.onChange(of: scenePhase, sceneDelegate.onScenePhaseChange)
		.environment(\.errorHandler, .init(sceneDelegate.handleError))
		.environment(\.presentIndicator, sceneDelegate.presentIndicator)
		.withNavigation(handler: sceneDelegate)
	}
}

// MARK: - Previews

#Preview {
	ContentView()
		.withEnvironment(appState: .shared)
}
