//
//  InterfaceSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		private typealias Localization = Localizable.Settings.Interface

		@EnvironmentObject private var preferences: Preferences

		var body: some View {
			Section(Localization.title) {
				// Enable Haptics
				ToggleOption(label: Localization.EnableHaptics.title,
							 description: Localization.EnableHaptics.description,
							 iconSymbolName: "alternatingcurrent",
							 isOn: $preferences.enableHaptics)

				// Use Grid View
				ToggleOption(label: Localization.UseGridView.title,
							 description: Localization.UseGridView.description,
							 iconSymbolName: "square.grid.2x2",
							 isOn: $preferences.cvUseGrid)
			}
		}
	}
}

struct InterfaceSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.InterfaceSection()
	}
}
