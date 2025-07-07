//
//  PrimaryButtonStyle.swift
//  Harbour
//
//  Created by royal on 29/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - PrimaryButtonStyle

struct PrimaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled: Bool
	let foregroundColor: Color
	let backgroundColor: Color
	let font: Font

	init(foregroundColor: Color = .white, backgroundColor: Color = .accentColor, font: Font = .body.weight(.semibold)) {
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.font = font
	}

	func makeBody(configuration: Configuration) -> some View {
		let base = configuration.label
			.font(font)
			.multilineTextAlignment(.center)
			.foregroundStyle(isEnabled ? foregroundColor : .secondary)
			.padding()
			.frame(maxWidth: .infinity, alignment: .center)

		Group {
			if #available(iOS 26.0, macOS 26.0, *) {
				base
			} else {
				base
					.background(isEnabled ? backgroundColor : Color.primaryGray.opacity(0.2), in: .buttonBorder)
			}
		}
		.contentShape(.buttonBorder)
//		#if os(iOS)
//		.contentShape(.contextMenuPreview, .buttonBorder)
//		#endif
//		.contentShape(.interaction, .buttonBorder)
		._glassEffectInteractive(tint: isEnabled ? backgroundColor : Color.primaryGray.opacity(0.2), enabled: isEnabled)
//		.modifier(ButtonScalesDownOnPressModifier(configuration: configuration))
		.animation(.default, value: isEnabled)
		.animation(.spring, value: configuration.isPressed)
	}
}

// MARK: - ButtonStyle+customPrimary

extension ButtonStyle where Self == PrimaryButtonStyle {
	static var customPrimary: Self { .init() }
	static func customPrimary(
		foregroundColor: Color = .white,
		backgroundColor: Color = .accentColor,
		font: Font = .body.weight(.semibold)
	) -> Self {
		.init(foregroundColor: foregroundColor, backgroundColor: backgroundColor, font: font)
	}
}
