//
//  ContainerCellBackground.swift
//  Harbour
//
//  Created by royal on 21/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainerCellBackground: View {
	@Environment(\.useColoredContainerCells) var useColoredContainerCells: Bool
	let state: PortainerKit.ContainerStatus?
	
	let fallback = Color(uiColor: .secondarySystemBackground)
	
	var body: some View {
		if useColoredContainerCells {
			ContainerRelativeShape()
				.fill(state?.color.opacity(0.15) ?? fallback)
				.background(Color(uiColor: .systemBackground))
		} else {
			ContainerRelativeShape()
				.fill(fallback)
		}
	}
}
