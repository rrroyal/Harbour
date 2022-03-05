//
//  ContainersListView.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainersListView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var sceneState: SceneState
	let containers: [PortainerKit.Container]

	let padding: Double = 10
	let spacing: Double = 10

    var body: some View {
		ScrollView {
			LazyVStack(spacing: spacing) {
				ForEach(containers) { container in
					NavigationLink(tag: container, selection: $sceneState.activeContainer, destination: {
						ContainerDetailView(container: container)
							.equatable()
							.environmentObject(sceneState)
							.environmentObject(portainer)
					}) {
						ContainerCell(container: container)
							.equatable()
							.contextMenu { ContainerContextMenu(container: container) }
							.onDrag { ContainersView.containerDragProvider(container: container) }
					}
					.buttonStyle(.decreasesOnPress)
				}
			}
			.padding(.horizontal)
		}
		.transition(.opacity)
		.animation(.easeInOut, value: containers.count)
    }
}

extension ContainersListView: Equatable {
	static func == (lhs: ContainersListView, rhs: ContainersListView) -> Bool {
		lhs.containers == rhs.containers
	}
}

struct ContainersListView_Previews: PreviewProvider {
    static var previews: some View {
		ContainersListView(containers: [])
    }
}
