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

	private let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)

	init(foregroundColor: Color = .white, backgroundColor: Color = .accentColor, font: Font = .body.weight(.semibold)) {
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.font = font
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(font)
			.multilineTextAlignment(.center)
			.foregroundStyle(isEnabled ? foregroundColor : .secondary)
			.padding()
			.frame(maxWidth: .infinity, alignment: .center)
			.background(isEnabled ? backgroundColor : Color.systemGray)
			.clipShape(roundedRectangle)
			.contentShape(roundedRectangle)
			.modifier(ButtonScalesDownOnPressModifier(configuration: configuration))
			.animation(Constants.Buttons.pressAnimation, value: isEnabled)
			.animation(Constants.Buttons.pressAnimation, value: configuration.isPressed)
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
