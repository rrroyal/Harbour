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
		let symbolVariants: SymbolVariants
		@Binding var isOn: Bool

		init(label: String,
			 description: String? = nil,
			 iconSymbolName: String,
			 symbolVariants: SymbolVariants = .fill,
			 isOn: Binding<Bool>) {
			self.label = label
			self.description = description
			self.iconSymbolName = iconSymbolName
			self.symbolVariants = symbolVariants
			self._isOn = isOn
		}

		var body: some View {
			Toggle(isOn: $isOn) {
				HStack(alignment: SettingsView.optionTitleAlignment) {
					OptionIcon(symbolName: iconSymbolName, color: .accentColor, symbolVariants: symbolVariants)
						.alignmentGuide(SettingsView.optionTitleAlignment) { $0[VerticalAlignment.center] }
						.animation(.easeInOut, value: isOn)

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
			.frame(minHeight: SettingsView.minimumCellHeight)
		}
	}
}
