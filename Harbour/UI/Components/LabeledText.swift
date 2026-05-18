//
//  LabeledText.swift
//  Harbour
//
//  Created by royal on 14/01/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

// MARK: - LabeledText

struct LabeledText: View {
	let content: String?

	init(_ content: String?) {
		self.content = if let content, !content.isReallyEmpty {
			content
		} else {
			nil
		}
	}

	var body: some View {
		Text(content ?? String(localized: "Generic.Empty"))
			.foregroundStyle(content != nil ? .primary : .secondary)
	}
}

// MARK: - LabeledTextWithIcon

struct LabeledTextWithIcon: View {
	let title: String?
	let systemImage: String

	init(_ title: String?, systemImage: String) {
		self.title = if let title, !title.isReallyEmpty {
			title
		} else {
			nil
		}
		self.systemImage = systemImage
	}

	var body: some View {
		Label(
			title ?? String(localized: "Generic.Empty"),
			systemImage: systemImage
		)
		.foregroundStyle(title != nil ? .primary : .secondary)
	}
}
