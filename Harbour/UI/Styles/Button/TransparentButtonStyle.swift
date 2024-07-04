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
	var includePadding = true

	private let paddingHorizontal: Double = 14
	private let paddingVertical: Double = 14
	private let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.multilineTextAlignment(.center)
			.padding(.horizontal, includePadding ? paddingHorizontal : 0)
			.padding(.vertical, includePadding ? paddingVertical : 0)
			.background(Color.primaryGray.opacity(configuration.isPressed ? 0.1 : 0), in: roundedRectangle)
			.contentShape(roundedRectangle)
			.modifier(ButtonScalesDownOnPressModifier(configuration: configuration))
			.animation(.default, value: isEnabled)
			.animation(.spring, value: configuration.isPressed)
//			.padding(.horizontal, -paddingHorizontal)
//			.padding(.vertical, -paddingVertical)
	}
}

// MARK: - ButtonStyle+customTransparent

extension ButtonStyle where Self == TransparentButtonStyle {
	static var customTransparent: Self { .init() }

	static func customTransparent(includePadding: Bool = true) -> Self {
		.init(includePadding: includePadding)
	}
}
