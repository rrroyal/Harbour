//
//  SettingsView+PortainerSection.swift
//  Harbour
//
//  Created by royal on 18/08/2021.
//

import SwiftUI
import UserNotifications

extension SettingsView {
	struct PortainerSection: View {
		@EnvironmentObject var portainer: Portainer
		@EnvironmentObject var preferences: Preferences
		
		@State private var isLoginSheetPresented: Bool = false
		@State private var isLogoutWarningPresented: Bool = false
		
		var autoRefreshIntervalDescription: String {
			guard preferences.autoRefreshInterval > 0 else {
				return "Off"
			}
			
			let formatter = DateComponentsFormatter()
			formatter.allowedUnits = [.second]
			formatter.unitsStyle = .full
			
			return formatter.string(from: preferences.autoRefreshInterval) ?? "\(preferences.autoRefreshInterval) second(s)"
		}
		
		@ViewBuilder
		var loggedInView: some View {
			/// Refresh containers in background
			ToggleOption(label: Localization.SETTINGS_BACKGROUND_REFRESH_TITLE.localizedString, description: Localization.SETTINGS_BACKGROUND_REFRESH_DESCRIPTION.localizedString, isOn: preferences.$enableBackgroundRefresh)
				.onChange(of: preferences.enableBackgroundRefresh, perform: setupBackgroundRefresh)
			
			/// Auto-refresh interval
			SliderOption(label: Localization.SETTINGS_AUTO_REFRESH_TITLE.localizedString, description: autoRefreshIntervalDescription, value: $preferences.autoRefreshInterval, range: 0...60, step: 1, onEditingChanged: setupAutoRefreshTimer)
				.disabled(!Portainer.shared.isLoggedIn)
			
			Button("Log out", role: .destructive) {
				UIDevice.current.generateHaptic(.warning)
				isLogoutWarningPresented = true
			}
			.alert(isPresented: $isLogoutWarningPresented) {
				Alert(title: Text("Are you sure?"),
					  primaryButton: .destructive(Text("Yes"), action: {
					UIDevice.current.generateHaptic(.heavy)
					portainer.logOut()
				}),
					  secondaryButton: .cancel()
				)
			}
		}
		
		var notLoggedInView: some View {
			Button("Log in") {
				UIDevice.current.generateHaptic(.soft)
				isLoginSheetPresented = true
			}
		}
		
		var body: some View {
			Section("Portainer") {
				/// Endpoint URL
				if let endpointURL = Preferences.shared.endpointURL {
					Labeled(label: "URL", content: endpointURL, monospace: true, lineLimit: 1)
				}
				
				/// Logged in/not logged in label
				if portainer.isLoggedIn {
					loggedInView
				} else {
					notLoggedInView
				}
			}
			.animation(.easeInOut, value: portainer.isLoggedIn)
			.animation(.easeInOut, value: Preferences.shared.endpointURL)
			.transition(.opacity)
			.sheet(isPresented: $isLoginSheetPresented) {
				LoginView()
			}
		}
		
		private func setupBackgroundRefresh(isOn: Bool) {
			guard isOn else {
				AppState.shared.cancelBackgroundRefreshTask()
				return
			}
			
			Task {
				do {
					try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
					AppState.shared.scheduleBackgroundRefreshTask()
				} catch {
					AppState.shared.cancelBackgroundRefreshTask()
					preferences.enableBackgroundRefresh = false
					AppState.shared.handle(error)
				}
			}
		}
		
		private func setupAutoRefreshTimer(isEditing: Bool) {
			guard !isEditing else { return }
			
			AppState.shared.setupAutoRefreshTimer(interval: preferences.autoRefreshInterval)
		}
	}
}
