//
//  ContainerGridView.swift
//  Harbour
//
//  Created by unitears on 04/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainerGridView: View {
	let containers: [PortainerKit.Container]
	
	let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns) {
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

struct ContainerGridView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerGridView(containers: [])
    }
}
