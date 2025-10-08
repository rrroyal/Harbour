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
	@Environment(SceneDelegate.self) private var sceneDelegate
	@EnvironmentObject private var portainerStore: PortainerStore
	var stack: Stack
	var setStackStateAction: (Bool) -> Void

	var body: some View {
		Group {
			if !stack._isStored {
				Button {
					Haptics.generateIfEnabled(.light)
					setStackStateAction(!stack.isOn)
				} label: {
					Label(
						stack.isOn ? "StackContextMenu.Stop" : "StackContextMenu.Start",
						systemImage: stack.isOn ? Stack.Status.inactive.icon : Stack.Status.active.icon
					)
				}
				.keyboardShortcut("s", modifiers: stack.isOn ? [.command, .shift] : .command)

				Divider()

				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					sceneDelegate.editedStack = stack
				} label: {
					Label("Generic.Edit", systemImage: SFSymbol.edit)
				}
				.keyboardShortcut("e", modifiers: .command)

				Button(role: .destructive) {
					Haptics.generateIfEnabled(.warning)
					sceneDelegate.stackToRemove = stack
				} label: {
					Label("Generic.Remove", systemImage: SFSymbol.remove)
				}
				.keyboardShortcut(.delete, modifiers: .command)
				.tint(.red)
			}

			if let portainerServerURL = portainerStore.serverURL,
			   let portainerDeeplink = PortainerDeeplink(baseURL: portainerServerURL)?.stackURL(stack: stack) {
				Divider()

				ShareLink("Generic.SharePortainerURL", item: portainerDeeplink)
					.keyboardShortcut("u", modifiers: .command)
			}
		}
		.labelStyle(.titleAndIcon)
	}
}
