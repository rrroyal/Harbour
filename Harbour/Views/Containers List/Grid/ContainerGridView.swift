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
	@EnvironmentObject var preferences: Preferences
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	let containers: [PortainerKit.Container]
	
	var columnCount: Int {
		horizontalSizeClass == .regular ? 6 : 3
	}
    
	var body: some View {
		ScrollView {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnCount)) {
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

struct ContainerGridView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerGridView(containers: [])
    }
}
