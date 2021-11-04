//
//  ContainerGridView.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainerGridView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var sceneState: SceneState
	let containers: [PortainerKit.Container]
	
	let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns) {
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
					.buttonStyle(DecreasesOnPressButtonStyle())
				}
			}
			.padding(.horizontal)
			.transition(.opacity)
			.animation(.easeInOut, value: containers.count)
		}
    }
}

struct ContainerGridView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerGridView(containers: [])
    }
}
