//
//  SettingsView+ToggleOption.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

internal extension SettingsView {
	struct ToggleOption: View {
		@Environment(\.isEnabled) private var isEnabled: Bool
		private let label: LocalizedStringKey
		private let description: LocalizedStringKey?
		private let iconSymbolName: String
		private let symbolVariants: SymbolVariants = .fill
		@Binding private var isOn: Bool

		init(
			_ label: LocalizedStringKey,
			description: LocalizedStringKey? = nil,
			iconSymbolName: String,
//			symbolVariants: SymbolVariants = .fill,
			isOn: Binding<Bool>
		) {
			self.label = label
			self.description = description
			self.iconSymbolName = iconSymbolName
//			self.symbolVariants = symbolVariants
			self._isOn = isOn
		}

		var body: some View {
			Toggle(isOn: $isOn) {
				HStack(alignment: .top) {
					OptionIcon(symbolName: iconSymbolName)
//						.animation(.default, value: isOn)

					VStack(alignment: .listRowSeparatorLeading, spacing: vstackSpacing) {
						Text(label)
							.font(labelFontHeadline)

						if let description {
							Text(description)
								.font(labelFontSubheadline)
								.foregroundStyle(.secondary)
						}
					}
					.padding(.trailing, 2)
				}
			}
			.frame(minHeight: description == nil ? SettingsView.minimumCellHeight : SettingsView.minimumCellHeightWithDescription)
		}
	}
}
