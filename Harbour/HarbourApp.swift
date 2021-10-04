//
//  HarbourApp.swift
//  Harbour
//
//  Created by unitears on 10/06/2021.
//

import SwiftUI
import Indicators

@main
struct HarbourApp: App {
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.indicatorOverlay(model: appState.indicators)
				.sheet(isPresented: $appState.isContainerConsoleSheetPresented, onDismiss: onContainerConsoleViewDismissed) {
					ContainerConsoleView()
				}
				.sheet(isPresented: $appState.isSetupSheetPresented, onDismiss: { Preferences.shared.finishedSetup = true }) {
					SetupView()
				}
				.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
				.defaultAppStorage(.group)
				.environmentObject(appState)
				.environmentObject(portainer)
				.environmentObject(preferences)
		}
	}
	
	private func onContainerConsoleViewDismissed() {
		guard preferences.persistAttachedContainer else {
			portainer.attachedContainer = nil
			return
		}
		
		guard preferences.displayContainerDismissedPrompt && portainer.attachedContainer != nil else { return }
		
		let indicatorID: String = "ContainerDismissedIndicator"
		let indicator: Indicators.Indicator = .init(id: indicatorID, icon: "terminal.fill", headline: Localization.CONTAINER_DISMISSED_NOTIFICATION_TITLE.localizedString, subheadline: Localization.CONTAINER_DISMISSED_NOTIFICATION_DESCRIPTION.localizedString, dismissType: .after(5), onTap: {
			UIDevice.current.generateHaptic(.light)
			appState.isContainerConsoleSheetPresented = true
			appState.indicators.dismiss(matching: indicatorID)
		})
		appState.indicators.display(indicator)
	}
	
	private func onDeviceDidShake(_: Notification) {
		guard portainer.attachedContainer != nil else { return }
		UIDevice.current.generateHaptic(.light)
		appState.isContainerConsoleSheetPresented = true
	}
}
