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
			(labels ?? [:])
				.map { .init($0, $1) }
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("ContainerDetailsView.Section.Labels")
		}
	}
}
