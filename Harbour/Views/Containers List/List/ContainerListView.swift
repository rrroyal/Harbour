//
//  ContainerListView.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainerListView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var sceneState: SceneState
	let containers: [PortainerKit.Container]

    var body: some View {
		ScrollView {
			LazyVStack {
				ForEach(containers) { container in
					NavigationLink(tag: container.id, selection: $sceneState.activeContainerID, destination: {
						ContainerDetailView(container: container)
							.environmentObject(sceneState)
							.environmentObject(portainer)
					}) {
						ContainerCell(container: container)
							.contextMenu {
								ContainerContextMenu(container: container)
							}
							.onDrag { ContainersView.containerDragProvider(container: container) }
					}
					.buttonStyle(.decreasesOnPress)
				}
			}
			.padding(.horizontal)
			.transition(.opacity)
			.animation(.easeInOut, value: containers.count)
		}
    }
}

struct ContainerListView_Previews: PreviewProvider {
    static var previews: some View {
		ContainerListView(containers: [])
    }
}
