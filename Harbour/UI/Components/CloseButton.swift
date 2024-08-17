//
//  CloseButton.swift
//  Harbour
//
//  Created by royal on 16/09/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

struct CloseButton: View {
	@Environment(\.dismiss) private var _dismiss
	var style: Style
	var dismissAction: (() -> Void)?

	init(style: Style = .text, dismissAction: (() -> Void)? = nil) {
		self.style = style
		self.dismissAction = dismissAction
	}

	var body: some View {
		Button {
			Haptics.generateIfEnabled(.sheetPresentation)
			dismissAction?() ?? _dismiss()
		} label: {
			switch style {
			case .text:
				Text("Generic.Close")
			case .circleButton:
				Image(systemName: "xmark")
					.font(.caption)
					.fontWeight(.bold)
					.foregroundStyle(.secondary)
					.imageScale(.medium)
					.padding(6)
					.background(.quinary, in: Circle())
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
	CloseButton(style: .circleButton)
		.padding(4)
		.background(Color.groupedBackground)
}

#Preview {
	CloseButton(style: .text)
		.padding(4)
		.background(Color.groupedBackground)
}
