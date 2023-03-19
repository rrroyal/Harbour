//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import PortainerKit

// TODO: Animate ContainerCell changes (i.e. state)

// MARK: - ContainersView

struct ContainersView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.containersViewUseGrid) private var useGrid: Bool
	let containers: [Container]

	@ViewBuilder
	private var containersList: some View {
		if useGrid {
			ContainersGridView(containers: containers)
		} else {
			ContainersListView(containers: containers)
		}
	}

	var body: some View {
		containersList
			.padding(.horizontal)
			.padding(.bottom)
			.navigationDestination(for: ContainerNavigationItem.self) { navigationItem in
				ContainerDetailsView(navigationItem: navigationItem)
			}
			.transition(.opacity)
			.animation(.easeInOut, value: useGrid)
//			.animation(.easeInOut, value: containers)
//			.animation(.easeInOut, value: portainerStore.selectedEndpoint == nil)
//			.animation(.easeInOut, value: portainerStore.containers.isEmpty)
	}
}

// MARK: - ContainersView+Equatable

/*
extension ContainersView: Equatable {
	static func == (lhs: ContainersView, rhs: ContainersView) -> Bool {
		lhs.useGrid == rhs.useGrid &&
		lhs.containers == rhs.containers
	}
}
 */

// MARK: - Previews

struct ContainersView_Previews: PreviewProvider {
	static var previews: some View {
		ContainersView(containers: [])
	}
}
