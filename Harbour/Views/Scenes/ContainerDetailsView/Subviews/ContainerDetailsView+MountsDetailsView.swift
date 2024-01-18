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

		private var data: [KeyValueListView.Entry] {
			(mounts ?? [])
				.map { KeyValueListView.Entry(key: $0.source, value: $0.destination) }
				.sorted(by: \.key)
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFont(ContainerDetailsView.sectionHeaderFont.monospaced())
				.contentFont(ContainerDetailsView.sectionContentFont.monospaced())
				.navigationTitle("ContainerDetailsView.Section.Mounts")
		}
	}
}
