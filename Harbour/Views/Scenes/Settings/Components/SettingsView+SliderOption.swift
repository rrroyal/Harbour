//
//  SettingsView+SliderOption.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import CommonHaptics

internal extension SettingsView {
	struct SliderOption: View {
		@Environment(\.isEnabled) private var isEnabled: Bool
		let label: String
		let description: String?
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
					.opacity(isEnabled ? .primary : .secondary)

					Slider(value: $value, in: range, step: step, onEditingChanged: onEditingChanged)
						.onChange(of: value) { _, newValue in
							if newValue > range.lowerBound && newValue < range.upperBound {
								Haptics.generateIfEnabled(.selectionChanged)
							}
						}
				}
			}
			.padding(.vertical, .small)
			.frame(minHeight: description == nil ? SettingsView.minimumCellHeight : SettingsView.minimumCellHeightWithDescription)
		}
	}
}
