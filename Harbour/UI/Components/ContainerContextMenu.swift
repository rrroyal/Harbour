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
	var onContainerAction: (() -> Void)?

	@ViewBuilder
	private var attachButton: some View {
		Button(action: attachAction) {
			Label("ContainerContextMenu.Attach", systemImage: SFSymbol.terminal)
		}
	}

	@ViewBuilder
	private var unpauseButton: some View {
		Button {
			executeAction(.unpause)
		} label: {
			Label(ContainerAction.unpause.title, systemImage: ContainerAction.unpause.icon)
		}
	}

	@ViewBuilder
	private var pauseButton: some View {
		Button {
			executeAction(.pause)
		} label: {
			Label(ContainerAction.pause.title, systemImage: ContainerAction.pause.icon)
		}
	}

	@ViewBuilder
	private var startButton: some View {
		Button {
			executeAction(.start)
		} label: {
			Label(ContainerAction.start.title, systemImage: ContainerAction.start.icon)
		}
	}

	@ViewBuilder
	private var stopButton: some View {
		Button {
			executeAction(.stop)
		} label: {
			Label(ContainerAction.stop.title, systemImage: ContainerAction.stop.icon)
		}
	}

	@ViewBuilder
	private var restartButton: some View {
		Button {
			executeAction(.restart)
		} label: {
			Label(ContainerAction.restart.title, systemImage: ContainerAction.restart.icon)
		}
	}

	@ViewBuilder
	private var killButton: some View {
		Button {
			executeAction(.kill, haptic: .heavy)
		} label: {
			Label(ContainerAction.kill.title, systemImage: ContainerAction.kill.icon)
		}
	}

	var body: some View {
		Group {
			if !container._isStored {
				switch container.state {
				case .created:
					pauseButton
					stopButton
					restartButton
					killButton
				case .running:
					pauseButton
					stopButton
					restartButton
					killButton
				case .paused:
					unpauseButton
					stopButton
					restartButton
					killButton
				case .restarting:
					pauseButton
					stopButton
					killButton
				case .removing:
					killButton
				case .exited:
					startButton
				case .dead:
					startButton
				case .none:
					unpauseButton
					startButton
					restartButton
					pauseButton
					stopButton
					killButton
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
	func attachAction() {
		print(#function)

//		Haptics.generateIfEnabled(.sheetPresentation)
//		do {
//			try Portainer.shared.attach(to: container)
//			sceneDelegate.isContainerConsoleSheetPresented = true
//		} catch {
//			sceneDelegate.handle(error)
//		}
	}

	func executeAction(_ action: ContainerAction, haptic: Haptics.HapticStyle = .medium) {
		Haptics.generateIfEnabled(haptic)

		presentIndicator(.containerActionExecute(containerName: container.displayName ?? container.id, containerAction: action, state: .loading))

		Task {
			do {
				try await portainerStore.execute(action, on: container.id)
				presentIndicator(.containerActionExecute(containerName: container.displayName ?? container.id, containerAction: action, state: .success))
				onContainerAction?()
			} catch {
				presentIndicator(.containerActionExecute(containerName: container.displayName ?? container.id, containerAction: action, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}
}
