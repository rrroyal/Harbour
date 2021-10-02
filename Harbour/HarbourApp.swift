//
//  HarbourApp.swift
//  Harbour
//
//  Created by unitears on 10/06/2021.
//

import SwiftUI
import Toasts

@main
struct HarbourApp: App {
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.toastsOverlay(model: appState.toasts)
				.sheet(isPresented: $appState.isContainerConsoleSheetPresented, onDismiss: onContainerConsoleViewDismissed) {
					ContainerConsoleView()
						.environmentObject(portainer)
				}
				.sheet(isPresented: $appState.isSetupSheetPresented, onDismiss: { Preferences.shared.launchedBefore = true }) {
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
		
		let toastID: String = "ContainerDismissedToast"
		let toast: Toasts.Toast = .init(id: toastID, dismissType: .after(5), icon: "terminal", title: Localization.CONTAINER_DISMISSED_NOTIFICATION_TITLE, description: Localization.CONTAINER_DISMISSED_NOTIFICATION_DESCRIPTION, style: .primary, onTap: {
			UIDevice.current.generateHaptic(.light)
			appState.isContainerConsoleSheetPresented = true
			appState.toasts.dismiss(matching: toastID)
		})
		appState.toasts.add(toast)
	}
	
	private func onDeviceDidShake(_: Notification) {
		guard portainer.attachedContainer != nil else { return }
		UIDevice.current.generateHaptic(.light)
		appState.isContainerConsoleSheetPresented = true
	}
}
