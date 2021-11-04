//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 21/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainersView: View {
	@Environment(\.useContainerGridView) var useContainerGridView: Bool
	let containers: [PortainerKit.Container]
	
    var body: some View {
		if useContainerGridView {
			ContainerGridView(containers: containers)
		} else {
			ContainerListView(containers: containers)
		}
    }
	
	static func containerDragProvider(container: PortainerKit.Container) -> NSItemProvider {
		return NSItemProvider()
	}
}

struct ContainersView_Previews: PreviewProvider {
    static var previews: some View {
        ContainersView(containers: [])
    }
}
