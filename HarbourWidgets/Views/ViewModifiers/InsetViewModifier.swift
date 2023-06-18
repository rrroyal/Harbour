//
//  InsetViewModifier.swift
//  HarbourWidgets
//
//  Created by royal on 11/06/2023.
//

import SwiftUI

// MARK: - InsetViewModifier

struct InsetViewModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.aspectRatio(1, contentMode: .fit)
			.clipShape(ContainerRelativeShape(), style: .init(antialiased: false)) // Antialiasing has some weird artifacts :(
			.background(
				ContainerRelativeShape()
					.fill(Color.widgetBackground)
					.shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 0)
			)
			.padding(10)
	}
}

// MARK: - Previews

#Preview {
	SelectContainerView(entry: .placeholder)
		.modifier(InsetViewModifier())
}
