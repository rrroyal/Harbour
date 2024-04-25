//
//  TransparentButtonStyle.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - TransparentButtonStyle

struct TransparentButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled: Bool

	private let paddingHorizontal: Double = 14
	private let paddingVertical: Double = 14
	private let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.multilineTextAlignment(.center)
			.padding(.horizontal, paddingHorizontal)
			.padding(.vertical, paddingVertical)
			.background(Color.lightGray.opacity(configuration.isPressed ? 0.16 : 0))
			.clipShape(roundedRectangle)
			.contentShape(roundedRectangle)
			.modifier(ButtonScalesDownOnPressModifier(configuration: configuration))
			.animation(Constants.Buttons.pressAnimation, value: isEnabled)
			.animation(Constants.Buttons.pressAnimation, value: configuration.isPressed)
//			.padding(.horizontal, -paddingHorizontal)
//			.padding(.vertical, -paddingVertical)
	}
}

// MARK: - ButtonStyle+customTransparent

extension ButtonStyle where Self == TransparentButtonStyle {
	static var customTransparent: Self { .init() }
}
