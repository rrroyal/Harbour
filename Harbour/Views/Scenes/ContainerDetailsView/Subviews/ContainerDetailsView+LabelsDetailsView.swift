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

		private var data: [KeyValueListView.Entry] {
			(labels ?? [:])
				.map { KeyValueListView.Entry(key: $0, value: $1) }
				.sorted(by: \.key)
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFont(ContainerDetailsView.sectionHeaderFont.monospaced())
				.contentFont(ContainerDetailsView.sectionContentFont.monospaced())
				.navigationTitle("ContainerDetailsView.Section.Labels")
		}
	}
}
