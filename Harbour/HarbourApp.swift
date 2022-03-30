//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import SwiftUI
import Indicators
import PortainerKit

@main
/// Main entry point for Harbour
struct HarbourApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
				.environmentObject(portainer)
				.environmentObject(preferences)
				.environment(\.useColumns, preferences.clUseColumns)
				.environment(\.useContainerGridView, preferences.clUseGridView)
				.environment(\.useColoredContainerCells, preferences.clUseColoredContainerCells)
		}
	}
}
