//
//  ContainersView+GridView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersView+GridView

extension ContainersView {
	struct GridView: View {
		@Environment(ContainersView.ViewModel.self) private var containersViewViewModel
		@Environment(SceneDelegate.self) private var sceneDelegate
		@Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

		private var cellMinimumSize: Double {
			#if os(iOS)
			switch horizontalSizeClass {
			case .regular:
				120
			default:
				100
			}
			#elseif os(macOS)
			100
			#endif
		}

		private var cellMaximumSize: Double {
			(cellMinimumSize * 2) + cellSpacing
		}

		private let cellSpacing: Double = 8

		let containers: [Container]

		var body: some View {
			LazyVGrid(columns: [.init(.adaptive(minimum: cellMinimumSize, maximum: cellMaximumSize))], spacing: cellSpacing) {
				ForEach(containers) { container in
					ContainersView.ContainerNavigationCell(container: container) {
						ContainerCell(container: container)
							.equatable()
							.id("ContainerCell.\(container._persistentID)")
							.tag(container._persistentID)
					}
					.transition(.opacity)
					.environment(\.parentShape, AnyShape(ContainerCell.roundedRectangleBackground))
				}
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ScrollView {
		ContainersView.GridView(containers: [.preview()])
			.padding()
	}
	.background(Color.groupedBackground)
	.environment(SceneDelegate())
	.withEnvironment(appState: .shared)
}
