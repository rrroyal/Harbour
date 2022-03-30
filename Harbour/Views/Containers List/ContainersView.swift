//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 21/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainersView: View {
	@Environment(\.useContainerGridView) var useContainerGridView
	let containers: [PortainerKit.Container]
	
    var body: some View {
		if useContainerGridView {
			ContainersGridView(containers: containers)
				.equatable()
		} else {
			ContainersListView(containers: containers)
				.equatable()
		}
    }
}

extension ContainersView: Equatable {
	static func == (lhs: ContainersView, rhs: ContainersView) -> Bool {
		lhs.containers == rhs.containers
	}
}

struct ContainersView_Previews: PreviewProvider {
    static var previews: some View {
		ContainersView(containers: [])
    }
}
