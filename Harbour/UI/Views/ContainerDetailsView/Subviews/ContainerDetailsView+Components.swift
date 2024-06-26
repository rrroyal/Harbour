//
//  ContainerDetailsView+Components.swift
//  Harbour
//
//  Created by royal on 03/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - ContainerDetailsView+Labeled

extension ContainerDetailsView {
	struct Labeled: View {
		let content: String

		init(_ content: String) {
			self.content = content
		}

		var body: some View {
			Text(content.isEmpty ? String(localized: "Generic.Empty") : content)
				.foregroundStyle(content.isEmpty ? .secondary : .primary)
				.modifier(LabelModifier())
		}
	}
}

// MARK: - ContainerDetailsView+LabeledWithIcon

extension ContainerDetailsView {
	struct LabeledWithIcon: View {
		let title: String
		let icon: String

		init(_ title: String, icon: String) {
			self.title = title
			self.icon = icon
		}

		var body: some View {
			Label(
				title.isEmpty ? String(localized: "Generic.Empty") : title,
				systemImage: icon
			)
			.foregroundStyle(title.isEmpty ? .secondary : .primary)
			.modifier(LabelModifier())
		}
	}
}

// MARK: - LabelModifier

private struct LabelModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.textSelection(.enabled)
	}
}
