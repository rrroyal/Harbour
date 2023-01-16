//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		private typealias Localization = Localizable.Settings.Interface

		@EnvironmentObject private var preferences: Preferences

		private var displayiPadOptions: Bool {
			UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad
		}

		var body: some View {
			Section(Localization.title) {
				// Display Summary
				ToggleOption(label: Localization.DisplaySummary.title,
							 description: Localization.DisplaySummary.description,
							 iconSymbolName: "square.text.square",
							 isOn: $preferences.cvDisplaySummary)
//				.symbolVariant(preferences.enableHaptics ? .none : .slash)

				if displayiPadOptions {
					// Use Two-Column Layout
					ToggleOption(label: Localization.UseColumns.title,
								 description: Localization.UseColumns.description,
//								 iconSymbolName: preferences.cvUseColumns ? "sidebar.squares.left" : "rectangle.stack",
								 iconSymbolName: "sidebar.squares.left",
//								 symbolVariants: .none,
								 isOn: $preferences.cvUseColumns)
				}

				// Use Grid View
				ToggleOption(label: Localization.UseGridView.title,
							 description: Localization.UseGridView.description,
//							 iconSymbolName: preferences.cvUseGrid ? "square.grid.2x2" : "rectangle.grid.1x2",
							 iconSymbolName: "square.grid.2x2",
							 isOn: $preferences.cvUseGrid)

				// Enable Haptics
				ToggleOption(label: Localization.EnableHaptics.title,
							 description: Localization.EnableHaptics.description,
							 iconSymbolName: "waveform",
							 isOn: $preferences.enableHaptics)
//				.symbolVariant(preferences.enableHaptics ? .none : .slash)

				// App Icon
				NavigationLinkOption(label: Localization.AppIcon.title, iconSymbolName: "app.badge") {
					Text("App Icon")
				}
			}
		}
	}
}

struct InterfaceSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.InterfaceSection()
	}
}
