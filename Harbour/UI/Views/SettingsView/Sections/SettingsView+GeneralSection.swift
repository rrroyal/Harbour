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
		@Environment(SettingsView.ViewModel.self) var viewModel

		var body: some View {
			#if os(iOS)
			NormalizedSection {
				// Enable Background Refresh
				ToggleOption(
					"SettingsView.General.EnableBackgroundRefresh.Title",
					description: "SettingsView.General.EnableBackgroundRefresh.Description",
					iconSymbolName: SFSymbol.reload,
					isOn: $preferences.enableBackgroundRefresh
				)
//				.symbolVariant(preferences.enableBackgroundRefresh ? .none : .slash)
				.id(SettingsView.ViewID.generalBackgroundRefresh)
			} header: {
				Text("SettingsView.General.Title")
			}
			#endif
		}
	}
}

// MARK: - Previews

/*
#Preview {
	SettingsView.GeneralSection()
}
*/
