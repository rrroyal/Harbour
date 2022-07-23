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
	@EnvironmentObject var preferences: Preferences
	@StateObject var sceneState = SceneState()

	var body: some View {
		NavigationStack(path: $sceneState.navigationPath) {
			ContainersView()
				.equatable()
				.navigationTitle(Localizable.harbour)
				.navigationBarTitleDisplayMode(.inline)
				.toolbarTitleMenu {
					// TODO: Switch endpoints here
					Text("TODO")
				}
				.toolbar {
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
		.environmentObject(sceneState)
	}
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(AppState.shared)
			.environmentObject(Preferences.shared)
	}
}
