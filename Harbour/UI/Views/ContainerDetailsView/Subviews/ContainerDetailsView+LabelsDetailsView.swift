//
//  ContainerDetailsView+LabelsDetailsView.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension ContainerDetailsView {
	struct LabelsDetailsView: View {
		let labels: [String: String]?

		private var data: [KeyValueEntry] {
			labels?
				.map { .init(key: $0, value: $1) }
				.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending } ?? []
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("ContainerDetailsView.Section.Labels")
		}
	}
}
