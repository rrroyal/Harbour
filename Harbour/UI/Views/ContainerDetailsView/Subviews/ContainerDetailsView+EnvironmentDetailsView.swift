//
//  ContainerDetailsView+EnvironmentDetailsView.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension ContainerDetailsView {
	struct EnvironmentDetailsView: View {
		let environment: [String]?

		private var data: [KeyValueEntry] {
			environment?
				.compactMap { pair in
					let split = pair.split(separator: "=")
					if let one = split[safe: 0], let two = split[safe: 1] {
						return .init(key: String(one), value: String(two))
					} else {
						return .init(key: "", value: pair)
					}
				}
				.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending } ?? []
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("ContainerDetailsView.Section.Environment")
		}
	}
}
