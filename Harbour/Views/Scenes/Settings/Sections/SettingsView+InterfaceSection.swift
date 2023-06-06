//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import CommonHaptics

extension SettingsView {
	struct InterfaceSection: View {
		private typealias Localization = Localizable.SettingsView.Interface

		@EnvironmentObject private var viewModel: ViewModel
		@EnvironmentObject private var preferences: Preferences

		var body: some View {
			Section(Localization.title) {
				#if ENABLE_PREVIEW_FEATURES
				// Display Summary
				ToggleOption(label: Localization.DisplaySummary.title,
							 description: Localization.DisplaySummary.description,
							 iconSymbolName: "square.text.square",
							 isOn: $preferences.cvDisplaySummary)
//				.symbolVariant(preferences.enableHaptics ? .none : .slash)
				#endif

				if viewModel.displayiPadOptions {
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
				AppIconMenu()
			}
		}
	}
}

// MARK: - SettingsView.InterfaceSection+AppIconMenu

private extension SettingsView.InterfaceSection {
	struct AppIconMenu: View {
		@Environment(\.errorHandler) private var errorHandler
		@State private var currentIcon: AppIcon = .current

		var body: some View {
			SettingsView.MenuOption(label: Localization.AppIcon.title, iconSymbolName: "app.badge") {
				Menu {
					ForEach(AppIcon.allCases) { icon in
						let isCurrent = UIApplication.shared.alternateIconName == icon.id

						Button {
							setIcon(icon)
						} label: {
							if isCurrent {
								Label(icon.name, systemImage: SFSymbol.checkmark)
							} else {
								Text(icon.name)
							}
						}
					}
				} label: {
					Text(currentIcon.name)
						.font(.callout)
						.fontWeight(.medium)
						.frame(maxWidth: .infinity, alignment: .trailing)
						.transition(.opacity)
						.animation(.easeInOut, value: currentIcon.id)
				}
			}
		}

		private func setIcon(_ icon: AppIcon) {
			Haptics.generateIfEnabled(.light)
			UIApplication.shared.setAlternateIconName(icon.id) { error in
				if let error {
					errorHandler(error)
				} else {
					currentIcon = icon
				}
			}
		}
	}
}

// MARK: - Previews

#Preview {
	SettingsView.InterfaceSection()
}
