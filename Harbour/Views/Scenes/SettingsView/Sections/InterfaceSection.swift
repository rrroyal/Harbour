//
//  InterfaceSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		@EnvironmentObject var preferences: Preferences

		var body: some View {
			Section(Localizable.Settings.Interface.title) {
				// Enable Haptics
				ToggleOption(label: Localizable.Settings.Interface.EnableHaptics.title,
							 description: Localizable.Settings.Interface.EnableHaptics.description,
							 iconSymbolName: "alternatingcurrent",
							 isOn: $preferences.enableHaptics)

				// Use Grid View
				ToggleOption(label: Localizable.Settings.Interface.UseGridView.title,
							 description: Localizable.Settings.Interface.UseGridView.description,
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
