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
	let containers: [ContainersView.ContainersStack]

	static let padding: Double = 10
	static let spacing: Double = 10

    var body: some View {
		Self._printChanges()
		return ScrollView {
			LazyVStack(spacing: Self.spacing) {
				ForEach(containers, id: \.stack) { group in
					StackView(stack: group.stack, containers: group.containers)
				}
			}
			.padding(.horizontal, Self.padding)
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

private extension ContainersListView {
	struct StackView: View {
		@EnvironmentObject var portainer: Portainer
		@EnvironmentObject var sceneState: SceneState
		let stack: String?
		let containers: [PortainerKit.Container]
		
		var body: some View {
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
			.background(stack != nil ? ContainerCell.backgroundShape.fill(ContainersView.stackBackground) : nil)
		}
	}
}

struct ContainersListView_Previews: PreviewProvider {
    static var previews: some View {
		ContainersListView(containers: [])
    }
}
