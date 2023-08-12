//
//  ButtonScalesDownOnPressModifier.swift
//  Harbour
//
//  Created by royal on 12/08/2023.
//

import SwiftUI

/// ViewModifier for buttons; scales down on press.
struct ButtonScalesDownOnPressModifier: ViewModifier {
	let configuration: ButtonStyle.Configuration

	func body(content: Content) -> some View {
		content
			.opacity(configuration.isPressed ? Constants.Buttons.pressedOpacity : 1)
			.scaleEffect(configuration.isPressed ? Constants.Buttons.pressedScale : 1)
			.animation(Constants.Buttons.pressAnimation, value: configuration.isPressed)
	}
}
