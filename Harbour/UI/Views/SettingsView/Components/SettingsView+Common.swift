//
//  SettingsView+Common.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - SettingsView+Common

internal extension SettingsView {
	static var labelFontHeadline: Font {
		#if os(iOS)
		.headline
		#else
		.body.weight(.medium)
		#endif
	}
	static let labelFontSubheadline: Font = .footnote

	static let vstackSpacing: Double = 2

	static let minimumCellHeight: Double = 36
	static let minimumCellHeightWithDescription: Double = 40
}

// MARK: - SettingsView+OptionIcon

internal extension SettingsView {
	struct OptionIcon: View {
		private let symbolName: String
		private let symbolVariants: SymbolVariants = .fill

		init(symbolName: String) {
			self.symbolName = symbolName
//			self.symbolVariants = symbolVariants
		}

		private let font: Font = .caption
		@ScaledMetric(relativeTo: .caption) private var backgroundSize = 24

		var body: some View {
			Image(systemName: symbolName)
				.symbolVariant(symbolVariants)
				.symbolRenderingMode(.hierarchical)
				.font(font.weight(.bold))
				.frame(width: backgroundSize, height: backgroundSize, alignment: .center)
				.foregroundStyle(Color.accentColor)
				.background(Color.accentColor.quaternary)
				.cornerRadius(6)
		}
	}
}
