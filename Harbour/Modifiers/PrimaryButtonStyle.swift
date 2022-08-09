//
//  PrimaryButtonStyle.swift
//  Harbour
//
//  Created by royal on 29/07/2022.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) var isEnabled
	let foregroundColor: Color
	let backgroundColor: Color
	let font: Font

	let pressedOpacity: Double = 0.75
	let pressedScale: Double = 0.975
	let pressAnimation: Animation = .interpolatingSpring(stiffness: 250, damping: 30)

	public init(foregroundColor: Color = .white, backgroundColor: Color = .accentColor, font: Font = .body.weight(.semibold)) {
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
			.background(isEnabled ? backgroundColor : Color(uiColor: .systemGray5))
			.cornerRadius(Constants.cornerRadius)
			.opacity(configuration.isPressed ? pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? pressedScale : 1)
			.animation(pressAnimation, value: configuration.isPressed)
			.animation(.easeInOut, value: isEnabled)
	}
}

extension ButtonStyle where Self == PrimaryButtonStyle {
	static var customPrimary: PrimaryButtonStyle { .init() }
	static func customPrimary(foregroundColor: Color = .white,
							  backgroundColor: Color = .accentColor,
							  font: Font = .body.weight(.semibold)) -> PrimaryButtonStyle {
		.init(foregroundColor: foregroundColor, backgroundColor: backgroundColor, font: font)
	}
}
