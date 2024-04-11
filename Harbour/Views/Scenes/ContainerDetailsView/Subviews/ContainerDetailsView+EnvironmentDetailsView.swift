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

		private var data: [KeyValueListView.Entry] {
			(environment ?? [])
				.map { key in
					let split = key.split(separator: "=")
					if let one = split[safe: 0], let two = split[safe: 1] {
						return KeyValueListView.Entry(key: String(one), value: String(two))
					} else {
						return KeyValueListView.Entry(key: "", value: key)
					}
				}
				.sorted(by: \.key)
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("ContainerDetailsView.Section.Environment")
		}
	}
}
