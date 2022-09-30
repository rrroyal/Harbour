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

	@Environment(\.portainerSelectedEndpoint) var portainerSelectedEndpoint
	@EnvironmentObject var sceneState: SceneState

	let containers: [Container]

	// TODO: Improve it for iPadOS/macOS
	private let columns: [GridItem] = .init(repeating: .init(.flexible(), spacing: Self.cellSpacing), count: 3)

	var body: some View {
		LazyVGrid(columns: columns, spacing: Self.cellSpacing) {
			ForEach(containers) { container in
				let navigationItem = ContainersView.ContainerNavigationItem(id: container.id, displayName: container.displayName, endpointID: portainerSelectedEndpoint)
				NavigationLink(value: navigationItem) {
					ContainerCell(container: container)
						.equatable()
						.contextMenu {
							ContainersView.ContainerContextMenu(container: container)
						}
						.tint(Color.primary)
						.transition(.opacity)
				}
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
