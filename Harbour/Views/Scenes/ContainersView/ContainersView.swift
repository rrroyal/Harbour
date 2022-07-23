//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

struct ContainersView: View {
	@Environment(\.containersViewUseGrid) var useGrid: Bool

	var body: some View {
		if useGrid {
			ContainersGridView()
		} else {
			ContainersListView()
		}
	}
}

extension ContainersView: Equatable {
	static func == (lhs: ContainersView, rhs: ContainersView) -> Bool {
		lhs.useGrid == rhs.useGrid
	}
}
