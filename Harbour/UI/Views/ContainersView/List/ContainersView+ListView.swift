//
//  ContainersView.ListView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersView+ListView

extension ContainersView {
	struct ListView: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@Environment(ContainersView.ViewModel.self) private var viewModel

		private let cellSpacing: Double = 8

		let containers: [Container]

		var body: some View {
			List {
				ForEach(containers) { container in
					ContainersView.ContainerNavigationCell(container: container) {
						ContainerCell(container: container)
							.equatable()
							.geometryGroup()
					}
				}
			}
			#if os(iOS)
			.listStyle(.insetGrouped)
			#elseif os(macOS)
			.listStyle(.inset)
			#endif
			.animation(.default, value: containers)
		}
	}
}

// MARK: - Previews

#Preview {
	ScrollView {
		ContainersView.ListView(containers: [.preview()])
			.padding()
	}
	.background(Color.groupedBackground)
	.environment(SceneDelegate())
	.withEnvironment()
}
