//
//  DecreasesOnPressButtonStyle.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import SwiftUI

struct DecreasesOnPressButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.contentShape(Rectangle())
			.multilineTextAlignment(.center)
			.opacity(configuration.isPressed ? Constants.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Constants.Buttons.pressedScale : 1)
			.animation(Constants.Buttons.pressAnimation, value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == DecreasesOnPressButtonStyle {
	static var decreasesOnPress: DecreasesOnPressButtonStyle { .init() }
}
