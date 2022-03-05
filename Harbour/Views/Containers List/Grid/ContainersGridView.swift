//
//  ContainersGridView.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainersGridView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var sceneState: SceneState
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	let containers: [PortainerKit.Container]
	
	let padding: Double = 10
	let spacing: Double = 10

	private var columns: Int {
		horizontalSizeClass == .regular ? 6 : 3
	}
			
	var body: some View {
		ScrollView {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)) {
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

extension ContainersGridView: Equatable {
	static func == (lhs: ContainersGridView, rhs: ContainersGridView) -> Bool {
		lhs.containers == rhs.containers
	}
}

struct ContainersGridView_Previews: PreviewProvider {
    static var previews: some View {
		ContainersGridView(containers: [])
    }
}
