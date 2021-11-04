//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by royal on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		@Environment(\.horizontalSizeClass) var horizontalSizeClass
		@EnvironmentObject var preferences: Preferences
		
		var body: some View {
			Section("Interface") {
				/// Enable haptics
				ToggleOption(label: Localization.SETTINGS_ENABLE_HAPTICS_TITLE.localized, description: Localization.SETTINGS_ENABLE_HAPTICS_DESCRIPTION.localized, isOn: $preferences.enableHaptics)
				
				/// Use Grid View
				ToggleOption(label: Localization.SETTINGS_CL_USE_GRID_VIEW_TITLE.localized, description: Localization.SETTINGS_CL_USE_GRID_VIEW_DESCRIPTION.localized, isOn: $preferences.clUseGridView)
				
				/// Use Two Panels
				if horizontalSizeClass == .regular {
					ToggleOption(label: Localization.SETTINGS_CL_USE_COLUMNS_TITLE.localized, description: Localization.SETTINGS_CL_USE_COLUMNS_DESCRIPTION.localized, isOn: $preferences.clUseColumns)
				}
				
				/// Use Colored Container Cells
				ToggleOption(label: Localization.SETTINGS_CL_USE_COLORED_CONTAINER_CELLS_TITLE.localized, description: Localization.SETTINGS_CL_USE_COLORED_CONTAINER_CELLS_DESCRIPTION.localized, isOn: $preferences.clUseColoredContainerCells)
				
				/// Display "Container dismissed" prompt
				ToggleOption(label: Localization.SETTINGS_CONTAINER_DISCONNECTED_PROMPT_TITLE.localized, description: Localization.SETTINGS_CONTAINER_DISCONNECTED_PROMPT_DESCRIPTION.localized, isOn: $preferences.displayContainerDismissedPrompt)
					.disabled(!preferences.persistAttachedContainer)
			}
		}
	}
}
