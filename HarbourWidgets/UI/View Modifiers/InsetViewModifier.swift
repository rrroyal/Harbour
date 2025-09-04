//
//  InsetViewModifier.swift
//  HarbourWidgets
//
//  Created by royal on 11/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - InsetViewModifier

struct InsetViewModifier: ViewModifier {
	@Environment(\.widgetRenderingMode) private var widgetRenderingMode

	private var fillColor: Color {
		Color.widgetBackground
			.opacity(widgetRenderingMode == .accented ? 0.04 : 1)
	}

	func body(content: Content) -> some View {
		content
			.background(
				ContainerRelativeShape()
					.fill(fillColor)
					.shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 0)
			)
	}
}

// MARK: - Previews

#Preview {
	StatusFeedbackView(mode: .containerNotFound)
		.modifier(InsetViewModifier())
}
