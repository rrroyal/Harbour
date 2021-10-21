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
		
		var body: some View {
			Group {
				Section("Portainer") {
					/// Endpoint URL
					if let endpointURL = Preferences.shared.endpointURL {
						Labeled(label: "URL", content: endpointURL, monospace: true, lineLimit: 1)
					}
					
					if preferences.endpointURL != nil {
						Button("Log out", role: .destructive) {
							UIDevice.current.generateHaptic(.warning)
							isLogoutWarningPresented = true
						}
						.confirmationDialog("Are you sure?", isPresented: $isLogoutWarningPresented, titleVisibility: .visible) {
							Button("Yup!", role: .destructive) {
								UIDevice.current.generateHaptic(.heavy)
								portainer.logOut()
							}
							
							Button("Nevermind", role: .cancel) {
								UIDevice.current.generateHaptic(.soft)
							}
						}
					} else {
						Button("Log in") {
							UIDevice.current.generateHaptic(.soft)
							isLoginSheetPresented = true
						}
					}
				}
				.sheet(isPresented: $isLoginSheetPresented) {
					LoginView()
				}
				
				if preferences.endpointURL != nil {
					Section("Data") {
						/// Persist attached container
						ToggleOption(label: Localization.SETTINGS_PERSIST_ATTACHED_CONTAINER_TITLE.localized, description: Localization.SETTINGS_PERSIST_ATTACHED_CONTAINER_DESCRIPTION.localized, isOn: $preferences.persistAttachedContainer)
						
						/// Refresh containers in background
						ToggleOption(label: Localization.SETTINGS_BACKGROUND_REFRESH_TITLE.localized, description: Localization.SETTINGS_BACKGROUND_REFRESH_DESCRIPTION.localized, isOn: preferences.$enableBackgroundRefresh)
							.onChange(of: preferences.enableBackgroundRefresh, perform: setupBackgroundRefresh)
						
						/// Auto-refresh interval
						SliderOption(label: Localization.SETTINGS_AUTO_REFRESH_TITLE.localized, description: autoRefreshIntervalDescription, value: $preferences.autoRefreshInterval, range: 0...60, step: 1, onEditingChanged: setupAutoRefreshTimer)
					}
				}
			}
			.transition(.opacity)
			.animation(.easeInOut, value: preferences.endpointURL)
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
