//
//  CloseButton.swift
//  Harbour
//
//  Created by royal on 16/09/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

struct CloseButton: View {
	var style: Style
	var action: () -> Void

	init(style: Style = .text, action: @escaping () -> Void) {
		self.style = style
		self.action = action
	}

	var body: some View {
		Button(action: action) {
			switch style {
			case .text:
				Text("Generic.Close")
			case .circleButton:
				Image(systemName: "xmark")
					.font(.caption2)
					.fontWeight(.bold)
					.foregroundStyle(.secondary)
					.padding(6)
					.background(.quaternary)
					.clipShape(Circle())
					.accessibilityRemoveTraits(.isImage)
					.tint(.primary)
			}
		}
		.keyboardShortcut(.cancelAction)
		.accessibilityLabel(Text("Generic.Close"))
		.accessibilityAddTraits(.isButton)
	}
}

// MARK: - CloseButton+Style

extension CloseButton {
	enum Style {
		case text
		case circleButton
	}
}

// MARK: - Previews

#Preview {
	CloseButton(action: { })
		.padding(4)
		.background(Color.groupedBackground)
		.previewLayout(.sizeThatFits)
}
