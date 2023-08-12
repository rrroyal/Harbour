//
//  SettingsView+GeneralSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// MARK: SettingsView+GeneralSection

extension SettingsView {
	struct GeneralSection: View {
		@EnvironmentObject private var viewModel: ViewModel
		@EnvironmentObject private var preferences: Preferences

		var body: some View {
			Section("SettingsView.General.Title") {
				// Enable Background Refresh
				ToggleOption(label: "SettingsView.General.EnableBackgroundRefresh.Title",
							 description: "SettingsView.General.EnableBackgroundRefresh.Description",
							 iconSymbolName: SFSymbol.reload,
							 isOn: $preferences.enableBackgroundRefresh)
//				.symbolVariant(preferences.enableBackgroundRefresh ? .none : .slash)
			}
		}
	}
}

// MARK: - Previews

/*
#Preview {
	SettingsView.GeneralSection()
}
*/
