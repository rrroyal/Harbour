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

	private var shouldUseTransparentBackground: Bool {
		widgetRenderingMode == .accented
	}

	func body(content: Content) -> some View {
		content
			.background(
				ContainerRelativeShape()
					.fill(Color.widgetBackground.opacity(shouldUseTransparentBackground ? 0.04 : 1))
					.shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 0)
			)
	}
}

// MARK: - Previews

#Preview {
	StatusFeedbackView(mode: .containerNotFound)
		.modifier(InsetViewModifier())
}
