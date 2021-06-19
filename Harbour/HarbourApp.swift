//
//  HarbourApp.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import SwiftUI
import AppNotifications

@main
struct HarbourApp: App {
	@StateObject var appState: AppState = AppState.shared
	@StateObject var portainer: Portainer = Portainer.shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
				.environmentObject(portainer)
				.notificationsOverlay(appState.errorNotifications, alignment: .top, anchor: .top)
				.notificationsOverlay(appState.persistenceNotifications, alignment: .bottom, anchor: .bottom)
				.sheet(isPresented: $appState.isSettingsViewPresented) {
					SettingsView()
						.environmentObject(portainer)
				}
				.sheet(isPresented: $appState.isContainerConsoleViewPresented, onDismiss: onContainerConsoleViewDismissed) {
					ContainerConsoleView()
						.environmentObject(portainer)
				}
				.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil)) { _ in
					guard portainer.attachedContainer != nil else { return }
					UIDevice.current.generateHaptic(.light)
					appState.isContainerConsoleViewPresented = true
				}
		}
	}
	
	private func onContainerConsoleViewDismissed() {
		guard portainer.attachedContainer != nil else { return }
		
		let notificationID: String = "ContainerDismissedNotification"
		let notification: AppNotifications.Notification = .init(id: notificationID, dismissType: .timeout(5), icon: "terminal", title: "Container dismissed", description: "Shake device or tap this message to open again.", backgroundStyle: .material(.regularMaterial), onTap: {
			UIDevice.current.generateHaptic(.light)
			appState.isContainerConsoleViewPresented = true
			appState.persistenceNotifications.dismiss(matching: notificationID)
		})
		appState.persistenceNotifications.add(notification)
	}
}
