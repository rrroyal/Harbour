//
//  SettingsView+InterfaceSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI
import TipKit

extension SettingsView {
	struct InterfaceSection: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@EnvironmentObject private var preferences: Preferences
		@Environment(SettingsView.ViewModel.self) var viewModel

		var body: some View {
			#if os(iOS) || targetEnvironment(macCatalyst)
			NormalizedSection {
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

				// App Icon
				#if os(iOS) && !targetEnvironment(macCatalyst)
				Group {
					AppIconMenu()
						.id(SettingsView.ViewID.interfaceAppIcon)
				}
				#endif
			} header: {
				Text("SettingsView.Interface.Title")
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

		private let tip = SettingsView.AppIconTip()

		var body: some View {
			SettingsView.MenuOption("SettingsView.Interface.AppIcon.Title", iconSymbolName: "app.badge") {
				Menu {
					ForEach(AppIcon.allCases) { icon in
						let isCurrent = AppIcon.current == icon

						Button {
							Haptics.generateIfEnabled(.light)
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
						.animation(.default, value: currentIcon)
				}
			}
			.popoverTip(tip, arrowEdge: .bottom)
			.tipViewStyle(NoCloseButtonTipViewStyle())
			.onDisappear {
				SettingsView.AppIconTip.shouldShow = false
			}
		}

		private func setIcon(_ icon: AppIcon) {
			Task {
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

// MARK: - SettingsView+AppIconTip

extension SettingsView {
	struct AppIconTip: Tip {
		let id = "appicon"

		let title = Text("SettingsView.AppIconTip.Title")
//		let image: Image? = Image(systemName: "app.badge")

		@Parameter(.transient)
		static var shouldShow: Bool = false

		var rules: [Rule] {
			#Rule(Self.$shouldShow) { $0 }
		}

		var options: [any TipOption] {
			IgnoresDisplayFrequency(true)
		}
	}
}

// MARK: - Previews

/*
#Preview {
	SettingsView.InterfaceSection()
}
*/
