//
//  SettingsView+ToggleOption.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

internal extension SettingsView {
	struct ToggleOption: View {
		@Environment(\.isEnabled) private var isEnabled: Bool
		let label: String
		let description: String?
		let iconSymbolName: String
		let iconColor: Color
		@Binding var isOn: Bool

		init(label: String, description: String? = nil, iconSymbolName: String, iconColor: Color = .accentColor, isOn: Binding<Bool>) {
			self.label = label
			self.description = description
			self.iconSymbolName = iconSymbolName
			self.iconColor = iconColor
			self._isOn = isOn
		}

		var body: some View {
			Toggle(isOn: $isOn) {
				HStack(alignment: SettingsView.optionTitleAlignment) {
					OptionIcon(symbolName: iconSymbolName, color: iconColor)
						.alignmentGuide(SettingsView.optionTitleAlignment) { $0[VerticalAlignment.center] }

					VStack(alignment: .listRowSeparatorLeading, spacing: vstackSpacing) {
						Text(label)
							.font(.headline)
							.alignmentGuide(SettingsView.optionTitleAlignment) { $0[VerticalAlignment.center] }

						if let description {
							Text(description)
								.font(.footnote)
								.foregroundStyle(.secondary)
						}
					}
					.padding(.trailing, 2)
				}
			}
		}
	}
}
