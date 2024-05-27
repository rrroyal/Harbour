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
		@Environment(SceneDelegate.self) private var sceneDelegate
		@EnvironmentObject private var preferences: Preferences
		@Environment(SettingsView.ViewModel.self) var viewModel

		var body: some View {
			#if os(iOS) || targetEnvironment(macCatalyst)
			Section("SettingsView.Interface.Title") {
				if viewModel.displayiPadOptions {
					// Use Two-Column Layout
					ToggleOption(
						"SettingsView.Interface.UseColumns.Title",
						description: "SettingsView.Interface.UseColumns.Description",
//						iconSymbolName: preferences.cvUseColumns ? "sidebar.squares.left" : "rectangle.stack",
						iconSymbolName: "sidebar.squares.left",
//						symbolVariants: .none,
						isOn: $preferences.useColumns
					)
					.id(SettingsView.ViewID.interfaceTwoColumnLayout)
				}

				// Enable Haptics
				#if os(iOS) && !targetEnvironment(macCatalyst)
				ToggleOption(
					"SettingsView.Interface.EnableHaptics.Title",
					description: "SettingsView.Interface.EnableHaptics.Description",
					iconSymbolName: "waveform",
					isOn: $preferences.enableHaptics
				)
//				.symbolVariant(preferences.enableHaptics ? .none : .slash)
				.id(SettingsView.ViewID.interfaceHaptics)
				#endif

				#if os(iOS) && !targetEnvironment(macCatalyst)
				// App Icon
				let appIconIsFocused = Binding<Bool>(
					get: { sceneDelegate.viewsToFocus.contains(SettingsView.ViewID.interfaceAppIcon) },
					set: { isFocused in
						let viewID = SettingsView.ViewID.interfaceAppIcon
						if isFocused {
							sceneDelegate.viewsToFocus.insert(viewID)
						} else {
							sceneDelegate.viewsToFocus.remove(viewID)
						}
					}
				)
				AppIconMenu()
					.id(SettingsView.ViewID.interfaceAppIcon)
					.listRowAttentionFocus(isFocused: appIconIsFocused)
				#endif
			}
			#endif
		}
	}
}

// MARK: - SettingsView.InterfaceSection+AppIconMenu

#if os(iOS)
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
				}
			}
			.animation(.smooth, value: currentIcon)
		}

		private func setIcon(_ icon: AppIcon) {
			Task {
				Haptics.generateIfEnabled(.light)
				do {
					currentIcon = icon
					try await AppIcon.setIcon(icon)
				} catch {
					currentIcon = .current
					errorHandler(error)
				}
			}
		}
	}
}
#endif

// MARK: - Previews

/*
#Preview {
	SettingsView.InterfaceSection()
}
*/
