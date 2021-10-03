//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by unitears on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		@EnvironmentObject var preferences: Preferences
		
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
			Section("Interface") {
				/// Enable haptics
				ToggleOption(label: Localization.SETTINGS_ENABLE_HAPTICS_TITLE, description: Localization.SETTINGS_ENABLE_HAPTICS_DESCRIPTION, isOn: $preferences.enableHaptics)
				
				/// Persist attached container
				ToggleOption(label: Localization.SETTINGS_PERSIST_ATTACHED_CONTAINER_TITLE, description: Localization.SETTINGS_PERSIST_ATTACHED_CONTAINER_DESCRIPTION, isOn: $preferences.persistAttachedContainer)
				
				/// Display "Container dismissed" prompt
				ToggleOption(label: Localization.SETTINGS_CONTAINER_DISCONNECTED_PROMPT_TITLE, description: Localization.SETTINGS_CONTAINER_DISCONNECTED_PROMPT_DESCRIPTION, isOn: $preferences.displayContainerDismissedPrompt)
					.disabled(!preferences.persistAttachedContainer)
				
				/// Auto-refresh interval
				SliderOption(label: Localization.SETTINGS_AUTO_REFRESH_TITLE, description: autoRefreshIntervalDescription, value: $preferences.autoRefreshInterval, range: 0...60, step: 1, onEditingChanged: setupAutoRefreshTimer)
					.disabled(!Portainer.shared.isLoggedIn)
			}
		}
		
		private func setupAutoRefreshTimer(isEditing: Bool) {
			guard !isEditing else { return }
			
			AppState.shared.setupAutoRefreshTimer(interval: preferences.autoRefreshInterval)
		}
	}
}
