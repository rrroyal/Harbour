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
		private typealias Localization = Localizable.SettingsView.General

		@EnvironmentObject private var viewModel: ViewModel
		@EnvironmentObject private var preferences: Preferences

		var body: some View {
			Section(Localization.title) {
				// Enable Background Refresh
				ToggleOption(label: Localization.EnableBackgroundRefresh.title,
							 description: Localization.EnableBackgroundRefresh.description,
							 iconSymbolName: SFSymbol.reload,
							 isOn: $preferences.enableBackgroundRefresh)
//				.symbolVariant(preferences.enableBackgroundRefresh ? .none : .slash)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	SettingsView.GeneralSection()
}
