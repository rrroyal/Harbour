//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by royal on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		@EnvironmentObject var preferences: Preferences
		
		var body: some View {
			Section("Interface") {
				/// Enable haptics
				ToggleOption(label: Localization.SETTINGS_ENABLE_HAPTICS_TITLE.localized, description: Localization.SETTINGS_ENABLE_HAPTICS_DESCRIPTION.localized, isOn: $preferences.enableHaptics)
				
				/// Use Grid View
				ToggleOption(label: Localization.SETTINGS_USE_GRID_VIEW_TITLE.localized, description: Localization.SETTINGS_USE_GRID_VIEW_DESCRIPTION.localized, isOn: $preferences.useGridView)
				
				/// Persist attached container
				ToggleOption(label: Localization.SETTINGS_PERSIST_ATTACHED_CONTAINER_TITLE.localized, description: Localization.SETTINGS_PERSIST_ATTACHED_CONTAINER_DESCRIPTION.localized, isOn: $preferences.persistAttachedContainer)
				
				/// Display "Container dismissed" prompt
				ToggleOption(label: Localization.SETTINGS_CONTAINER_DISCONNECTED_PROMPT_TITLE.localized, description: Localization.SETTINGS_CONTAINER_DISCONNECTED_PROMPT_DESCRIPTION.localized, isOn: $preferences.displayContainerDismissedPrompt)
					.disabled(!preferences.persistAttachedContainer)
			}
		}
	}
}