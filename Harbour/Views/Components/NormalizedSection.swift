//
//  NormalizedSection.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - NormalizedSection

struct NormalizedSection<Content: View, Header: View>: View {
	var content: () -> Content
	var header: () -> Header

	init(
		@ViewBuilder content: @escaping () -> Content,
		@ViewBuilder header: @escaping () -> Header = { EmptyView() }
	) {
		self.content = content
		self.header = header
	}

	var body: some View {
		Section {
			content()
				.font(.callout)
		} header: {
			header()
				.font(.footnote)
				.textCase(.uppercase)
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
