//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 21/10/2021.
//

// TODO: Add `.equatable()` back when compiler starts working lmao

import SwiftUI
import PortainerKit

struct ContainersView: View {
	@Environment(\.useContainerGridView) var useContainerGridView: Bool
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
		lhs.containers == rhs.containers && lhs.useContainerGridView == rhs.useContainerGridView
	}
}

struct ContainersView_Previews: PreviewProvider {
    static var previews: some View {
		ContainersView(containers: [])
    }
}
