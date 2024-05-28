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
	var labelContent: () -> LabelContent
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
			presentIndicator(.copied(content))

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
	}
}

extension CopyButton where LabelContent == Label<Text, Image> {
	init(
		_ title: LocalizedStringKey = "Generic.Copy",
		icon: String = SFSymbol.copy,
		content: String?
	) {
		self.content = content
		self.labelContent = {
			Label(title, systemImage: icon)
		}
	}
}
