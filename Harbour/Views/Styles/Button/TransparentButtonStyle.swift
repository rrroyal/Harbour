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
			.background(Color(uiColor: .systemGray5).opacity(configuration.isPressed ? Constants.secondaryOpacity : 0))
			.cornerRadius(Constants.cornerRadius)
			.opacity(configuration.isPressed ? Constants.buttonPressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Constants.buttonPressedSize : 1)
			.animation(Constants.springAnimation, value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == TransparentButtonStyle {
	static var customTransparent: TransparentButtonStyle { .init() }
}
