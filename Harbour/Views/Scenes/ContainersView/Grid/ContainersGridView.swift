//
//  ContainersGridView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import PortainerKit

// MARK: - ContainersGridView

struct ContainersGridView: View {
	private static let cellSpacing: Double = 8

	@EnvironmentObject private var sceneState: SceneState
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?

	let containers: [Container]

	private var columns: [GridItem] {
		let count = horizontalSizeClass == .regular ? 6 : 3
		return .init(repeating: .init(.flexible(), spacing: Self.cellSpacing), count: count)
	}

	var body: some View {
		LazyVGrid(columns: columns, spacing: Self.cellSpacing) {
			ForEach(containers) { container in
				ContainersView.ContainerNavigationCell(container: container) {
					ContainerCell(container: container)
				}
				.transition(.opacity)
			}
		}
		.padding(.horizontal)
		.background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
		.animation(.easeInOut, value: containers)
	}
}

// MARK: - Previews

struct ContainersGridView_Previews: PreviewProvider {
	static var previews: some View {
		ContainersGridView(containers: [])
	}
}
