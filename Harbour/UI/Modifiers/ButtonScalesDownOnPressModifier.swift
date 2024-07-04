//
//  ButtonScalesDownOnPressModifier.swift
//  Harbour
//
//  Created by royal on 12/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

/// ViewModifier for buttons; scales down on press.
struct ButtonScalesDownOnPressModifier: ViewModifier {
	static let pressedOpacity: Double = 0.8
	static let pressedScale: Double = 0.98

	let configuration: ButtonStyle.Configuration

	func body(content: Content) -> some View {
		content
			.opacity(configuration.isPressed ? Self.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Self.pressedScale : 1)
			.animation(.default, value: configuration.isPressed)
	}
}
