//
//  ContainerListView.swift
//  Harbour
//
//  Created by unitears on 04/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainerListView: View {
	let containers: [PortainerKit.Container]

    var body: some View {
		ScrollView {
			LazyVStack {
				ForEach(containers) { container in
					NavigationLink(destination: ContainerDetailView(container: container)) {
						ContainerCell(container: container)
							.contextMenu {
								ContainerContextMenu(container: container)
							}
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

struct ContainerListView_Previews: PreviewProvider {
    static var previews: some View {
		ContainerListView(containers: [])
    }
}
