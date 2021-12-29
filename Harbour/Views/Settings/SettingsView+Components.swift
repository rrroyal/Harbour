//
//  SettingsView+Components.swift
//  Harbour
//
//  Created by royal on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	internal static let standaloneLabelFont: Font = Font.body.weight(.medium)
	
	internal static let vstackSpacing: Double = 4
	
	struct OptionIcon: View {
		let symbolName: String
		let color: Color
		
		let font = Font.footnote
		let uiFont = UIFont.preferredFont(forTextStyle: .footnote)
		
		var body: some View {
			Image(systemName: symbolName)
				.symbolVariant(.fill)
				.font(font.weight(.bold))
				.frame(width: uiFont.pointSize * 2, height: uiFont.pointSize * 2, alignment: .center)
				.foregroundStyle(color)
				.background(color.opacity(Constants.candyOpacity))
				.cornerRadius(6)
		}
	}
	
	struct SliderOption: View {
		@Environment(\.isEnabled) var isEnabled: Bool
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
						Text(LocalizedStringKey(label))
							.font(.headline)
						
						Spacer()
						
						if let description = description {
							Text(LocalizedStringKey(description))
								.font(.body)
								.foregroundStyle(.secondary)
						}
					}
					.opacity(isEnabled ? 1 : Constants.secondaryOpacity)
					
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
	
	struct ToggleOption: View {
		@Environment(\.isEnabled) var isEnabled: Bool
		let label: String
		let description: String?
		let iconSymbolName: String
		let iconColor: Color
		@Binding var isOn: Bool
		
		var body: some View {
			Toggle(isOn: $isOn) {
				HStack {
					OptionIcon(symbolName: iconSymbolName, color: iconColor)
						.frame(maxHeight: .infinity, alignment: .top)
					
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
				}
				.padding(.vertical, .small)
				.opacity(isEnabled ? 1 : Constants.secondaryOpacity)
			}
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}
	
	struct NavigationLinkOption<Destination: View>: View {
		let label: String
		let iconSymbolName: String
		let iconColor: Color
		let destination: Destination
		
		init(label: String, iconSymbolName: String, iconColor: Color, destination: @escaping () -> Destination) {
			self.label = label
			self.iconSymbolName = iconSymbolName
			self.iconColor = iconColor
			self.destination = destination()
		}
		
		var body: some View {
			NavigationLink(destination: destination) {
				HStack {
					OptionIcon(symbolName: iconSymbolName, color: iconColor)
					Text(LocalizedStringKey(label))
						.font(standaloneLabelFont)
				}
			}
		}
	}
}
