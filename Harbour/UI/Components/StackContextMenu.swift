//
//  StackContextMenu.swift
//  Harbour
//
//  Created by royal on 03/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - StackContextMenu

struct StackContextMenu: View {
	@Environment(\.portainerServerURL) private var portainerServerURL
	@EnvironmentObject private var portainerStore: PortainerStore
	var stack: Stack
	var setStackStateAction: (Bool) -> Void
	var removeStackAction: () -> Void

	var body: some View {
		if portainerStore.loadingStackIDs.contains(stack.id) {
			Text("Generic.Loading")
			Divider()
		}

		Button {
			Haptics.generateIfEnabled(.light)
			setStackStateAction(!stack.isOn)
		} label: {
			Label(
				stack.isOn ? "StackContextMenu.StopStack" : "StackContextMenu.StartStack",
				systemImage: stack.isOn ? SFSymbol.stop : SFSymbol.start
			)
		}

		Divider()

		Button {

		} label: {
			Label("StackContextMenu.EditStack", systemImage: SFSymbol.edit)
		}

		Button(role: .destructive) {
			Haptics.generateIfEnabled(.warning)
			removeStackAction()
		} label: {
			Label("StackContextMenu.RemoveStack", systemImage: SFSymbol.remove)
		}

		if let portainerDeeplink = PortainerDeeplink(baseURL: portainerServerURL)?.stackURL(stack: stack) {
			Divider()

			ShareLink("Generic.SharePortainerURL", item: portainerDeeplink)
		}
	}
}
