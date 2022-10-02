//
//  SettingsView+SliderOption.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

internal extension SettingsView {
	struct SliderOption: View {
		@Environment(\.isEnabled) private var isEnabled: Bool
		let label: String
		let description: String?
		let iconSymbolName: String
		let iconColor: Color
		@Binding var value: Double
		let range: ClosedRange<Double>
		let step: Double
		let onEditingChanged: (Bool) -> Void

		var body: some View {
			HStack {
				OptionIcon(symbolName: iconSymbolName, color: iconColor)
					.frame(maxHeight: .infinity, alignment: .top)

				VStack(spacing: vstackSpacing) {
					HStack {
						Text(label)
							.font(.headline)

						Spacer()

						if let description = description {
							Text(description)
								.font(.body)
								.foregroundStyle(.secondary)
						}
					}
					.opacity(isEnabled ? .primary : .secondary)

					Slider(value: $value, in: range, step: step, onEditingChanged: onEditingChanged)
						.onChange(of: value) {
							if $0 > range.lowerBound && $0 < range.upperBound {
								UIDevice.generateHaptic(.selectionChanged)
							}
						}
				}
			}
			.padding(.vertical, .small)
		}
	}
}
