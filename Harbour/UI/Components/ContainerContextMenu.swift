//
//  ContainerContextMenu.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import IndicatorsKit
import PortainerKit
import SwiftUI

struct ContainerContextMenu: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.portainerServerURL) private var portainerServerURL: URL?
	@Environment(\.portainerSelectedEndpoint) private var portainerSelectedEndpoint: Endpoint?
	var container: Container
	var removeContainerAction: () -> Void

	private let killActionHaptic: Haptics.HapticStyle = .heavy

	@ViewBuilder
	private var attachButton: some View {
		Button(action: attachAction) {
			Label("ContainerContextMenu.Attach", systemImage: SFSymbol.terminal)
		}
	}

	var body: some View {
		Group {
			if !container._isStored {
				switch container.state {
				case .created:
					ActionButton(container: container, action: .pause)
					ActionButton(container: container, action: .stop)
					ActionButton(container: container, action: .restart)
					Divider()
					ActionButton(container: container, action: .kill, role: .destructive, haptic: killActionHaptic)
				case .running:
					ActionButton(container: container, action: .pause)
					ActionButton(container: container, action: .stop)
					ActionButton(container: container, action: .restart)
					Divider()
					ActionButton(container: container, action: .kill, role: .destructive, haptic: killActionHaptic)
				case .paused:
					ActionButton(container: container, action: .unpause)
					ActionButton(container: container, action: .stop)
					ActionButton(container: container, action: .restart)
					Divider()
					ActionButton(container: container, action: .kill, role: .destructive, haptic: killActionHaptic)
				case .restarting:
					ActionButton(container: container, action: .pause)
					ActionButton(container: container, action: .stop)
					Divider()
					ActionButton(container: container, action: .kill, role: .destructive, haptic: killActionHaptic)
				case .removing:
					ActionButton(container: container, action: .kill, role: .destructive, haptic: killActionHaptic)
				case .exited:
					ActionButton(container: container, action: .start)
				case .dead:
					ActionButton(container: container, action: .start)
				case .none:
					ActionButton(container: container, action: .unpause)
					ActionButton(container: container, action: .start)
					ActionButton(container: container, action: .restart)
					ActionButton(container: container, action: .pause)
					ActionButton(container: container, action: .stop)
					Divider()
					ActionButton(container: container, action: .kill, role: .destructive, haptic: killActionHaptic)
				}

				Divider()

				Button(role: .destructive) {
					Haptics.generateIfEnabled(.warning)
					removeContainerAction()
				} label: {
					Label("Generic.Remove", systemImage: SFSymbol.remove)
				}

				if let portainerDeeplink = PortainerDeeplink(baseURL: portainerServerURL)?.containerURL(containerID: container.id, endpointID: portainerSelectedEndpoint?.id) {
					Divider()

					ShareLink("Generic.SharePortainerURL", item: portainerDeeplink)
				}
			}

//			#if ENABLE_PREVIEW_FEATURES
//			Divider()
//
//			if containerState.isContainerOn {
//				attachButton
//			}
//			#endif
		}
		.labelStyle(.titleAndIcon)
	}
}

// MARK: - ContainerContextMenu+Actions

private extension ContainerContextMenu {
	func attachAction() {
		print(#function)

		Haptics.generateIfEnabled(.sheetPresentation)
//		do {
//			try Portainer.shared.attach(to: container)
//			sceneDelegate.isContainerConsoleSheetPresented = true
//		} catch {
//			sceneDelegate.handle(error)
//		}
	}
}

// MARK: -

private extension ContainerContextMenu {
	struct ActionButton: View {
		@EnvironmentObject private var portainerStore: PortainerStore
		@Environment(\.presentIndicator) private var presentIndicator
		@Environment(\.errorHandler) private var errorHandler
		var container: Container
		var action: ContainerAction
		var role: ButtonRole?
		var haptic: Haptics.HapticStyle

		init(
			container: Container,
			action: ContainerAction,
			role: ButtonRole? = nil,
			haptic: Haptics.HapticStyle = .medium
		) {
			self.container = container
			self.action = action
			self.role = role
			self.haptic = haptic
		}

		var body: some View {
			Button(role: role) {
				executeAction()
			} label: {
				Label(action.title, systemImage: action.icon)
			}
		}

		func executeAction() {
			Haptics.generateIfEnabled(haptic)

			presentIndicator(.containerActionExecute(container.id, container.displayName, action, state: .loading))

			Task {
				do {
					try await portainerStore.execute(action, on: container.id)
					portainerStore.refreshContainers(ids: [container.id], errorHandler: errorHandler)
					presentIndicator(.containerActionExecute(container.id, container.displayName, action, state: .success))
				} catch {
					presentIndicator(.containerActionExecute(container.id, container.displayName, action, state: .failure(error)))
					errorHandler(error, showIndicator: false)
				}
			}
		}
	}
}
