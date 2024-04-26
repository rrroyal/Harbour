//
//  NormalizedSection.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - NormalizedSection

struct NormalizedSection<Content: View, Header: View, Footer: View>: View {
	var content: () -> Content
	var header: () -> Header
	var footer: () -> Footer

	init(
		@ViewBuilder content: @escaping () -> Content,
		@ViewBuilder header: @escaping () -> Header = { EmptyView() },
		@ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
	) {
		self.content = content
		self.header = header
		self.footer = footer
	}

	var body: some View {
		Section {
			content()
				.font(.callout)
		} header: {
			header()
				.font(.footnote)
				.textCase(.uppercase)
		} footer: {
			footer()
		}
	}
}

// MARK: - Previews

#Preview {
	Form {
		NormalizedSection {
			Text(verbatim: "Content")
		} header: {
			Text(verbatim: "Header")
		}
	}
}
