//
//  SettingsView+SliderOption.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

internal extension SettingsView {
	struct SliderOption: View {
		@Environment(\.isEnabled) private var isEnabled: Bool
		let label: LocalizedStringResource
		let description: LocalizedStringResource?
		let iconSymbolName: String
		@Binding var value: Double
		let range: ClosedRange<Double>
		let step: Double
		let onEditingChanged: (Bool) -> Void

		var body: some View {
			HStack {
				OptionIcon(symbolName: iconSymbolName)
					.frame(maxHeight: .infinity, alignment: .top)

				VStack(spacing: vstackSpacing) {
					HStack {
						Text(label)
							.font(labelFontHeadline)

						Spacer()

						if let description = description {
							Text(description)
								.font(labelFontSubheadline)
								.foregroundStyle(.secondary)
						}
					}
					.opacity(isEnabled ? 1 : Constants.secondaryOpacity)

					Slider(value: $value, in: range, step: step, onEditingChanged: onEditingChanged)
						.onChange(of: value) { _, newValue in
							if newValue > range.lowerBound && newValue < range.upperBound {
								Haptics.generateIfEnabled(.selectionChanged)
							}
						}
				}
			}
			.padding(.vertical, 6)
			.frame(minHeight: description == nil ? SettingsView.minimumCellHeight : SettingsView.minimumCellHeightWithDescription)
		}
	}
}
