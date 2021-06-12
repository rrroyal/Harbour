//
//  PrimaryButtonStyle.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
	let color: Color

	public init(color: Color = .accentColor) {
		self.color = color
	}
		
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.body.weight(.semibold))
			.padding()
			.frame(maxWidth: .infinity, alignment: .center)
			.background(
				RoundedRectangle(cornerRadius: Globals.Views.cornerRadius, style: .continuous)
					.fill(color)
			)
			.compositingGroup()
			.opacity(configuration.isPressed ? Globals.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Globals.Buttons.pressedSize : 1)
			.animation(Globals.Views.springAnimation, value: configuration.isPressed)
		}
}
