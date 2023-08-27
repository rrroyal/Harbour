//
//  SettingsView+GeneralSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: SettingsView+GeneralSection

extension SettingsView {
	struct GeneralSection: View {
		@EnvironmentObject private var preferences: Preferences
		@Bindable var viewModel: SettingsView.ViewModel

		var body: some View {
			Section("SettingsView.General.Title") {
				// Enable Background Refresh
				ToggleOption("SettingsView.General.EnableBackgroundRefresh.Title",
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
