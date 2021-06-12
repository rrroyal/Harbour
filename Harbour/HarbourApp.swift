//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import SwiftUI

@main
struct HarbourApp: App {
	@StateObject var appState: AppState = AppState.shared
	@StateObject var portainer: Portainer = Portainer.shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
				.environmentObject(portainer)
		}
	}
}
