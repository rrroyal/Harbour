//
//  SettingsView+Common.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// MARK: - SettingsView+Common

internal extension SettingsView {
	static let standaloneLabelFont: Font = .body.weight(.medium)
	static let vstackSpacing: Double = 4
}

// MARK: - SettingsView+OptionIcon

internal extension SettingsView {
	struct OptionIcon: View {
		let symbolName: String
		let color: Color

		let font: Font = .caption
		@ScaledMetric(relativeTo: .caption) var backgroundSize = 24

		var body: some View {
			Image(systemName: symbolName)
				.symbolVariant(.fill)
				.symbolRenderingMode(.hierarchical)
				.font(font.weight(.bold))
				.frame(width: backgroundSize, height: backgroundSize, alignment: .center)
				.foregroundStyle(Color.accentColor)
				.background(Color.accentColor.opacity(.candy))
				.cornerRadius(6)
		}
	}
}

// MARK: - SettingsView+OptionTitleAlignment

internal extension SettingsView {
	private struct OptionTitleAlignment: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat {
			context[VerticalAlignment.center]
		}
	}

	/// A guide for aligning titles.
	static let optionTitleAlignment = VerticalAlignment(
		OptionTitleAlignment.self
	)
}
