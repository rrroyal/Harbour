//
//  HarbourApp.swift
//  Harbour
//
//  Created by unitears on 10/06/2021.
//

import SwiftUI
import AppNotifications

@main
struct HarbourApp: App {
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.notificationsOverlay(appState.errorNotifications, alignment: .top, anchor: .top)
				.notificationsOverlay(appState.persistenceNotifications, alignment: .bottom, anchor: .bottom)
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
		
		let notificationID: String = "ContainerDismissedNotification"
		let notification: AppNotifications.Notification = .init(id: notificationID, dismissType: .after(5), icon: "terminal", title: String.Localization.CONTAINER_DISMISSED_NOTIFICATION_TITLE, description: String.Localization.CONTAINER_DISMISSED_NOTIFICATION_DESCRIPTION, style: .primary, onTap: {
			UIDevice.current.generateHaptic(.light)
			appState.isContainerConsoleSheetPresented = true
			appState.persistenceNotifications.dismiss(matching: notificationID)
		})
		appState.persistenceNotifications.add(notification)
	}
	
	private func onDeviceDidShake(_: Notification) {
		guard portainer.attachedContainer != nil else { return }
		UIDevice.current.generateHaptic(.light)
		appState.isContainerConsoleSheetPresented = true
	}
}
