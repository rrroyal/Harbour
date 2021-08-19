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
			Section(header: Text("Interface")) {
				/// Enable haptics
				ToggleOption(label: "%SETTINGS_ENABLE_HAPTICS_TITLE%", description: "%SETTINGS_ENABLE_HAPTICS_DESCRIPTION%", isOn: $preferences.enableHaptics)
				
				/// Display "Container dismissed" prompt
				ToggleOption(label: "%SETTINGS_CONTAINER_DISCONNECTED_PROMPT_TITLE%", description: "%SETTINGS_CONTAINER_DISCONNECTED_PROMPT_DESCRIPTION%", isOn: $preferences.displayContainerDismissedPrompt)
				
				/// Auto-refresh interval
				SliderOption(label: "%SETTINGS_AUTO_REFRESH%", description: autoRefreshIntervalDescription, value: $preferences.autoRefreshInterval, range: 0...60, step: 1, onEditingChanged: setupAutoRefreshTimer)
			}
		}
		
		private func setupAutoRefreshTimer(isEditing: Bool) {
			guard !isEditing else { return }
			
			AppState.shared.setupAutoRefreshTimer(interval: preferences.autoRefreshInterval)
		}
	}
}
