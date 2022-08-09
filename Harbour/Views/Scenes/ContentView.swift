//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//

import SwiftUI
import Indicators

// MARK: - ContentView

struct ContentView: View {
	@EnvironmentObject var appState: AppState
	@EnvironmentObject var portainerStore: PortainerStore
	@EnvironmentObject var preferences: Preferences
	@StateObject var sceneState = SceneState()

	var body: some View {
		NavigationStack(path: $sceneState.navigationPath) {
			ContainersView()
//				.equatable()
				.navigationTitle(Localizable.appName)
				.navigationBarTitleDisplayMode(.inline)
				// TODO: Hide menu if no endpoints
				.toolbarTitleMenu(isVisible: !portainerStore.endpoints.isEmpty) {
					// TODO: Switch endpoints here
					Text("TODO")
				}
				.toolbar {
					ToolbarTitle(title: Localizable.appName, subtitle: sceneState.isLoadingMainScreenData ? Localizable.Generic.loading : nil)

					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: {
							UIDevice.generateHaptic(.sheetPresentation)
							sceneState.isSettingsSheetPresented = true
						}, label: {
							Image(systemName: "gear")
						})
					}
				}
		}
		.indicatorOverlay(model: sceneState.indicators)
		.sheet(isPresented: $sceneState.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: .constant(!preferences.finishedSetup)) {
			SetupView()
		}
		.environmentObject(sceneState)
	}
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(AppState.shared)
			.environmentObject(PortainerStore.shared)
			.environmentObject(Preferences.shared)
	}
}
