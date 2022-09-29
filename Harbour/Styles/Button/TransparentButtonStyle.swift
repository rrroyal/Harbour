//
//  TransparentButtonStyle.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import SwiftUI

struct TransparentButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.multilineTextAlignment(.center)
			.padding()
			.background(Color(uiColor: .systemGray5).opacity(configuration.isPressed ? Constants.secondaryOpacity : 0))
			.cornerRadius(Constants.cornerRadius)
			.opacity(configuration.isPressed ? Constants.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Constants.Buttons.pressedScale : 1)
			.animation(Constants.Buttons.pressAnimation, value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == TransparentButtonStyle {
	static var customTransparent: TransparentButtonStyle { .init() }
}
