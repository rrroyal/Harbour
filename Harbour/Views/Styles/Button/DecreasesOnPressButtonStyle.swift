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
			.contentShape(Rectangle())
			.multilineTextAlignment(.center)
			// .compositingGroup()
			.opacity(configuration.isPressed ? Constants.buttonPressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Constants.buttonPressedSize : 1)
			.animation(Constants.springAnimation, value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == DecreasesOnPressButtonStyle {
	static var decreasesOnPress: DecreasesOnPressButtonStyle { .init() }
}
