//
//  StackDetailsView+StackEnvironmentView.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - StackDetailsView+StackEnvironmentView

extension StackDetailsView {
	struct StackEnvironmentView: View {
		var entries: [Stack.EnvironmentEntry]?

		private var keyValueListData: [KeyValueEntry] {
			entries?
				.map { .init(key: $0.name, value: $0.value) }
				.sorted() ?? []
		}

		var body: some View {
			KeyValueListView(data: keyValueListData)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("StackDetailsView.Environment")
		}
	}
}

// MARK: - Previews

#Preview {
	StackDetailsView.StackEnvironmentView(entries: [])
}
