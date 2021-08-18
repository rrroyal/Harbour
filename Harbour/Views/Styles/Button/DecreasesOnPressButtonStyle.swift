//
//  DecreasesOnPressButtonStyle.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import SwiftUI

struct DecreasesOnPressButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.compositingGroup()
			.opacity(configuration.isPressed ? Globals.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Globals.Buttons.pressedSize : 1)
			.animation(.interpolatingSpring(stiffness: 250, damping: 15), value: configuration.isPressed)
	}
}
