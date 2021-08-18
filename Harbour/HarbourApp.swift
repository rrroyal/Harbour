//
//  HarbourApp.swift
//  Harbour
//
//  Created by unitears on 10/06/2021.
//

import SwiftUI
import AppNotifications
import LoadingIndicator

@main
struct HarbourApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject var appState: AppState = .shared
	@StateObject var portainer: Portainer = .shared
	@StateObject var preferences: Preferences = .shared

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
				.environmentObject(portainer)
				.environmentObject(preferences)
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
		}
	}
	
	private func onContainerConsoleViewDismissed() {
		guard preferences.displayContainerDismissedPrompt && portainer.attachedContainer != nil else { return }
		
		let notificationID: String = "ContainerDismissedNotification"
		let notification: AppNotifications.Notification = .init(id: notificationID, dismissType: .timeout(5), icon: "terminal", title: "%CONTAINER_DISMISSED_NOTIFICATION_HEADLINE%", description: "%CONTAINER_DISMISSED_NOTIFICATION_DESCRIPTION%", backgroundStyle: .material(.regularMaterial), onTap: {
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
