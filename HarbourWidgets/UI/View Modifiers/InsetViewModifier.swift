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
	func body(content: Content) -> some View {
		content
			.clipShape(ContainerRelativeShape(), style: .init(antialiased: false)) // Antialiasing has some weird artifacts :(
			.background(
				ContainerRelativeShape()
					.fill(Color.widgetBackground)
					.shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 0)
			)
	}
}

// MARK: - Previews

#Preview {
	StatusFeedbackView(entry: .placeholder, mode: .containerNotFound)
		.modifier(InsetViewModifier())
}
