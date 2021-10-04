//
//  DecreasesOnPressButtonStyle.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct DecreasesOnPressButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.multilineTextAlignment(.center)
			// .compositingGroup()
			.opacity(configuration.isPressed ? Globals.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Globals.Buttons.pressedSize : 1)
			.animation(Globals.Views.springAnimation, value: configuration.isPressed)
	}
}
