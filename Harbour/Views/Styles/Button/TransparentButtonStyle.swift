//
//  TransparentButtonStyle.swift
//  Harbour
//
//  Created by royal on 02/10/2021.
//

import SwiftUI

struct TransparentButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.multilineTextAlignment(.center)
			.padding()
			.background(Color(uiColor: .systemGray5).opacity(configuration.isPressed ? Globals.Views.secondaryOpacity : 0))
			.cornerRadius(Globals.Views.cornerRadius)
			.opacity(configuration.isPressed ? Globals.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Globals.Buttons.pressedSize : 1)
			.animation(Globals.Views.springAnimation, value: configuration.isPressed)
	}
}
