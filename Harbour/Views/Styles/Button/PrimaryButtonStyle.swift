//
//  PrimaryButtonStyle.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
	let foregroundColor: Color
	let backgroundColor: Color

	public init(foregroundColor: Color = .white, backgroundColor: Color = .accentColor) {
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundColor(foregroundColor)
			.font(.body.weight(.semibold))
			.padding()
			.frame(maxWidth: Globals.Views.maxButtonWidth, alignment: .center)
			.background(backgroundColor)
			.cornerRadius(Globals.Views.cornerRadius)
			// .compositingGroup()
			.opacity(configuration.isPressed ? Globals.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Globals.Buttons.pressedSize : 1)
			.animation(Globals.Views.springAnimation, value: configuration.isPressed)
	}
}
