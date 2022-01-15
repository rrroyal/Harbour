//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by royal on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	struct InterfaceSection: View {
		@Environment(\.horizontalSizeClass) var horizontalSizeClass
		@EnvironmentObject var preferences: Preferences
		
		var body: some View {
			Section("Interface") {
				/// Enable haptics
				ToggleOption(label: Localization.SETTINGS_ENABLE_HAPTICS_TITLE.localized, description: Localization.SETTINGS_ENABLE_HAPTICS_DESCRIPTION.localized, iconSymbolName: "alternatingcurrent", iconColor: .purple, isOn: $preferences.enableHaptics)
				
				/// Use Grid View
				ToggleOption(label: Localization.SETTINGS_CL_USE_GRID_VIEW_TITLE.localized, description: Localization.SETTINGS_CL_USE_GRID_VIEW_DESCRIPTION.localized, iconSymbolName: "square.grid.2x2", iconColor: .mint, isOn: $preferences.clUseGridView)
				
				/// Use Two Panels
				if UIApplication.isMacCatalyst || horizontalSizeClass == .regular {
					ToggleOption(label: Localization.SETTINGS_CL_USE_COLUMNS_TITLE.localized, description: Localization.SETTINGS_CL_USE_COLUMNS_DESCRIPTION.localized, iconSymbolName: "rectangle.leftthird.inset.filled", iconColor: .teal, isOn: $preferences.clUseColumns)
				}
				
				/// Use Colored Container Cells
				ToggleOption(label: Localization.SETTINGS_CL_USE_COLORED_CONTAINER_CELLS_TITLE.localized, description: Localization.SETTINGS_CL_USE_COLORED_CONTAINER_CELLS_DESCRIPTION.localized, iconSymbolName: "sparkles", iconColor: .pink, isOn: $preferences.clUseColoredContainerCells)
				
				/// App icon
				#if !targetEnvironment(macCatalyst)
				NavigationLinkOption(label: "App Icon", iconSymbolName: "app.badge", iconColor: .indigo) {
					AppIconView()
				}
				#endif
			}
		}
	}
	
	#if !targetEnvironment(macCatalyst)
	private struct AppIconView: View {
		var body: some View {
			ScrollView {
				LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 3)) {
					ForEach(UIApplication.appIcons, id: \.self) { icon in
						Button(action: {
							UIDevice.generateHaptic(.soft)
							if let icon = icon {
								UIApplication.shared.setAlternateIconName("AppIcon-\(icon)")
							} else {
								UIApplication.shared.setAlternateIconName(nil)
							}
						}) {
							Image("App Icons/\(icon ?? "Default")")
								.resizable()
								.aspectRatio(1, contentMode: .fit)
								.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
						}
						.buttonStyle(.decreasesOnPress)
						.padding(10)
					}
				}
			}
			.navigationTitle("App Icon")
		}
	}
	#endif
}
