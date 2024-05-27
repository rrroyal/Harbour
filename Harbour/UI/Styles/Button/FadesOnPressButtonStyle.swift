//
//  FadesOnPressButtonStyle.swift
//  Harbour
//
//  Created by royal on 17/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - FadesOnPressButtonStyle

struct FadesOnPressButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.opacity(configuration.isPressed ? ButtonScalesDownOnPressModifier.pressedOpacity : 1)
			.animation(.smooth, value: isEnabled)
			.animation(.spring, value: configuration.isPressed)
	}
}

// MARK: - ButtonStyle+fadesOnPress

extension ButtonStyle where Self == FadesOnPressButtonStyle {
	static var fadesOnPress: Self { .init() }
}
