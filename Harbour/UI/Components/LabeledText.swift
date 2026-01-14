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

	private var contentReadable: String {
		if let content, !content.isReallyEmpty {
			content
		} else {
			String(localized: "Generic.Empty")
		}
	}

	init(_ content: String?) {
		self.content = content
	}

	var body: some View {
		Text(contentReadable)
			.foregroundStyle((content?.isReallyEmpty ?? true) ? .secondary : .primary)
	}
}

// MARK: - LabeledTextWithIcon

struct LabeledTextWithIcon: View {
	let title: String?
	let systemImage: String

	private var titleReadable: String {
		if let title, !title.isReallyEmpty {
			title
		} else {
			String(localized: "Generic.Empty")
		}
	}

	init(_ title: String?, systemImage: String) {
		self.title = title
		self.systemImage = systemImage
	}

	var body: some View {
		Label(
			titleReadable,
			systemImage: systemImage
		)
		.foregroundStyle((title?.isReallyEmpty ?? true) ? .secondary : .primary)
	}
}
