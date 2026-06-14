//
//  StacksView+CreatorSheetContentView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

extension StacksView {
	struct CreatorSheetContentView: View {
		@Environment(PortainerStore.self) private var portainerStore

		var body: some View {
			NavigationStack {
				CreateStackCreatorView(
					portainerStore: portainerStore,
					onStackCreation: { _ in
						portainerStore.refreshStacks()
						portainerStore.refreshContainers()
					}
				)
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.addingCloseButton()
			}
		}
	}
}

#Preview {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	StacksView.CreatorSheetContentView()
		.environment(portainerStore)
}
