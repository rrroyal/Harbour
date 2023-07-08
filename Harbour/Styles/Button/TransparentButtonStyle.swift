//
//  TransparentButtonStyle.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import SwiftUI

struct TransparentButtonStyle: ButtonStyle {
	private let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .circular)

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.multilineTextAlignment(.center)
			.padding()
			.background(Color.lightGray.opacity(configuration.isPressed ? ViewOpacity.secondary.rawValue : 0))
			.clipShape(roundedRectangle)
			.contentShape(roundedRectangle)
			.opacity(configuration.isPressed ? Constants.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Constants.Buttons.pressedScale : 1)
			.animation(Constants.Buttons.pressAnimation, value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == TransparentButtonStyle {
	static var customTransparent: Self { .init() }
}
