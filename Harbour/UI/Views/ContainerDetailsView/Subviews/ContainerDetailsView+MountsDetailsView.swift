//
//  ContainerDetailsView+MountsDetailsView.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

extension ContainerDetailsView {
	struct MountsDetailsView: View {
		let mounts: [PortainerKit.MountPoint]?

		private var data: [KeyValueEntry] {
			mounts?
				.map { .init(key: $0.source, value: $0.destination) }
				.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending } ?? []
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("ContainerDetailsView.Section.Mounts")
		}
	}
}
