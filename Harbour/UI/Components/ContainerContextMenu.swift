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
	@Environment(\.presentIndicator) private var presentIndicator
	var container: Container
	var onContainerAction: () -> Void

//	@ViewBuilder
//	private var attachButton: some View {
//		Button(action: attachAction) {
//			Label("ContainerContextMenu.Attach", systemImage: SFSymbol.terminal)
//		}
//	}

	var body: some View {
		Group {
			if !container._isStored {
				ForEach(ContainerAction.actionsForState(container.state), id: \.rawValue) { action in
					Button {
						executeAction(action)
					} label: {
						Label(action.title, systemImage: action.icon)
					}
				}

				Divider()

				Button(role: .destructive) {
					Haptics.generateIfEnabled(.warning)
					sceneDelegate.containerToRemove = container
				} label: {
					Label("ContainerContextMenu.Remove", systemImage: SFSymbol.remove)
				}
			}

			if let portainerServerURL = portainerStore.serverURL,
			   let portainerDeeplink = PortainerDeeplink(baseURL: portainerServerURL)?.containerURL(containerID: container.id, endpointID: portainerStore.selectedEndpoint?.id) {
				Divider()

				ShareLink("Generic.SharePortainerURL", item: portainerDeeplink)
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
	func executeAction(_ action: ContainerAction, haptic: Haptics.HapticStyle = .medium) {
		Haptics.generateIfEnabled(haptic)

		presentIndicator(.containerActionExecute(containerName: container.displayName ?? container.id, containerAction: action, state: .loading))

		Task {
			do {
				try await portainerStore.execute(action, on: container.id)
				presentIndicator(.containerActionExecute(containerName: container.displayName ?? container.id, containerAction: action, state: .success))
				onContainerAction()
			} catch {
				presentIndicator(.containerActionExecute(containerName: container.displayName ?? container.id, containerAction: action, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}
}
