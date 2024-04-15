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
			mounts?.map { .init($0.source, $0.destination) } ?? []
		}

		var body: some View {
			KeyValueListView(data: data)
				.headerFontDesign(.monospaced)
				.contentFontDesign(.monospaced)
				.navigationTitle("ContainerDetailsView.Section.Mounts")
		}
	}
}
