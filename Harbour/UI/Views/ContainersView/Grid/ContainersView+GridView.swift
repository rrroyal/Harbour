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
		@Environment(SceneDelegate.self) private var sceneDelegate
		@Environment(ContainersView.ViewModel.self) private var viewModel
		@Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

		let containers: [Container]

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

		var body: some View {
			ScrollView {
				LazyVGrid(columns: [.init(.adaptive(minimum: cellMinimumSize, maximum: cellMaximumSize))], spacing: cellSpacing) {
					ForEach(containers) { container in
						ContainersView.ContainerNavigationCell(container: container) {
							ContainerCell(container: container)
								.equatable()
								.geometryGroup()
						}
					}
				}
				.padding(.horizontal)
				.padding(.bottom)
				#if os(macOS)
				.padding(.top)
				#endif
			}
			.animation(.default, value: containers)
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
	.withEnvironment()
}
