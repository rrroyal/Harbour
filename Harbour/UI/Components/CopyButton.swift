//
//  CopyButton.swift
//  Harbour
//
//  Created by royal on 08/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

struct CopyButton<LabelContent: View>: View {
	@Environment(\.presentIndicator) private var presentIndicator
	var content: String?
	@ViewBuilder var labelContent: () -> LabelContent

	init(
		content: String?,
		@ViewBuilder label labelContent: @escaping () -> LabelContent
	) {
		self.content = content
		self.labelContent = labelContent
	}

	var body: some View {
		Button {
			Haptics.generateIfEnabled(.selectionChanged)
			presentIndicator(.copied(nil))

			#if os(macOS)
			if let content {
				NSPasteboard.general.setString(content, forType: .string)
			}
			#else
			UIPasteboard.general.string = content
			#endif
		} label: {
			labelContent()
				.disabled(content == nil)
		}
		.keyboardShortcut("c", modifiers: .command)
	}
}

extension CopyButton where LabelContent == Label<Text, Image> {
	init(
		_ title: LocalizedStringResource = "Generic.Copy",
		icon: String = SFSymbol.copy,
		content: String?
	) {
		self.content = content
		self.labelContent = {
			Label(title, systemImage: icon)
		}
	}
}
