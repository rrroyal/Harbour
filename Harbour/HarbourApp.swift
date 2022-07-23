//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

@main
struct HarbourApp: App {
	@StateObject var appState: AppState = .shared
	@StateObject var portainerStore: PortainerStore = .shared
	@StateObject var preferences: Preferences = .shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.containersViewUseGrid, preferences.cvUseGrid)
				.environmentObject(appState)
				.environmentObject(portainerStore)
				.environmentObject(preferences)
		}
		.defaultAppStorage(Preferences.ud)
	}
}
