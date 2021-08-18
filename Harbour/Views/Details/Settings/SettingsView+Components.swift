//
//  SettingsView+Components.swift
//  Harbour
//
//  Created by unitears on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	fileprivate static let vstackSpacing: Double = 4
	
	struct SliderOption: View {
		let label: String
		let description: String?
		@Binding var value: Double
		let range: ClosedRange<Double>
		let step: Double
		let onEditingChanged: (Bool) -> Void
		
		var body: some View {
			VStack(spacing: vstackSpacing) {
				HStack {
					Text(LocalizedStringKey(label))
						.font(.headline)
					
					Spacer()
					
					if let description = description {
						Text(LocalizedStringKey(description))
							.font(.body)
							.foregroundStyle(.secondary)
					}
				}
				
				Slider(value: $value, in: range, step: step, onEditingChanged: onEditingChanged)
			}
			.padding(.vertical, .small)
		}
	}
	
	struct ToggleOption: View {
		let label: String
		let description: String?
		@Binding var isOn: Bool
		
		var body: some View {
			Toggle(isOn: $isOn) {
				VStack(alignment: .leading, spacing: vstackSpacing) {
					Text(LocalizedStringKey(label))
						.font(.headline)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					if let description = description {
						Text(LocalizedStringKey(description))
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
				.padding(.vertical, .small)
			}
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}
}
