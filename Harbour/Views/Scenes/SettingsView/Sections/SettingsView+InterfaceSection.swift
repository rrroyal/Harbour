//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		@EnvironmentObject private var preferences: Preferences
		@Bindable var viewModel: SettingsView.ViewModel

		var body: some View {
			Section("SettingsView.Interface.Title") {
//				#if ENABLE_PREVIEW_FEATURES
//				// Display Summary
//				ToggleOption(label: "SettingsView.Interface.DisplaySummary.Title",
//							 description: "SettingsView.Interface.DisplaySummary.Description",
//							 iconSymbolName: "square.text.square",
//							 isOn: $preferences.cvDisplaySummary)
//				#endif

				if viewModel.displayiPadOptions {
					// Use Two-Column Layout
					ToggleOption("SettingsView.Interface.UseColumns.Title",
								 description: "SettingsView.Interface.UseColumns.Description",
//								 iconSymbolName: preferences.cvUseColumns ? "sidebar.squares.left" : "rectangle.stack",
								 iconSymbolName: "sidebar.squares.left",
//								 symbolVariants: .none,
								 isOn: $preferences.cvUseColumns)
				}

				// Use Grid View
				ToggleOption("SettingsView.Interface.UseGridView.Title",
							 description: "SettingsView.Interface.UseGridView.Description",
//							 iconSymbolName: preferences.cvUseGrid ? "square.grid.2x2" : "rectangle.grid.1x2",
							 iconSymbolName: "square.grid.2x2",
							 isOn: $preferences.cvUseGrid)

				// Enable Haptics
				ToggleOption("SettingsView.Interface.EnableHaptics.Title",
							 description: "SettingsView.Interface.EnableHaptics.Description",
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
			SettingsView.MenuOption("SettingsView.Interface.AppIcon.Title", iconSymbolName: "app.badge") {
				Menu {
					ForEach(AppIcon.allCases) { icon in
						let isCurrent = AppIcon.current == icon

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
			Task {
				Haptics.generateIfEnabled(.light)
				do {
					try await AppIcon.setIcon(icon)
					currentIcon = icon
				} catch {
					errorHandler(error)
				}
			}
		}
	}
}

// MARK: - Previews

/*
#Preview {
	SettingsView.InterfaceSection()
}
*/
