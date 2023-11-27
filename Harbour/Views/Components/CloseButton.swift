//
//  CloseButton.swift
//  Harbour
//
//  Created by royal on 16/09/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

struct CloseButton: View {
	let action: () -> Void

	init(action: @escaping () -> Void) {
		self.action = action
	}

	var body: some View {
		Button(action: action) {
			/*
			Image(systemName: "xmark")
				.font(.caption2)
				.fontWeight(.black)
				.foregroundStyle(.tertiary)
				.padding(6)
				.background(.quaternary)
				.clipShape(Circle())
				.accessibilityLabel(Text("Generic.Close"))
				.accessibilityAddTraits(.isButton)
				.accessibilityRemoveTraits(.isImage)
				.tint(.primary)
			 */
			Text("Generic.Close")
		}
		.keyboardShortcut(.cancelAction)
	}
}

#Preview {
	CloseButton(action: { })
		.padding(4)
		.background(Color.groupedBackground)
		.previewLayout(.sizeThatFits)
}
