//
//  PrimaryButtonStyle.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) var isEnabled: Bool
	let foregroundColor: Color
	let backgroundColor: Color
	let font: Font

	public init(foregroundColor: Color = .white, backgroundColor: Color = .accentColor, font: Font = .body.weight(.semibold)) {
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.font = font
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.multilineTextAlignment(.center)
			.foregroundColor(isEnabled ? foregroundColor : .secondary)
			.font(font)
			.padding()
			.frame(maxWidth: .infinity, alignment: .center)
			.background(isEnabled ? backgroundColor : Color(uiColor: .systemGray5))
			.cornerRadius(Constants.cornerRadius)
			// .compositingGroup()
			.opacity(configuration.isPressed ? Constants.buttonPressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Constants.buttonPressedSize : 1)
			.animation(Constants.springAnimation, value: configuration.isPressed)
			.animation(.easeInOut, value: isEnabled)
	}
}

extension ButtonStyle where Self == PrimaryButtonStyle {
	static var customPrimary: PrimaryButtonStyle { .init() }
	static func customPrimary(foregroundColor: Color = .white, backgroundColor: Color = .accentColor, font: Font = .body.weight(.semibold)) -> PrimaryButtonStyle { .init(foregroundColor: foregroundColor, backgroundColor: backgroundColor, font: font) }
}
