//
//  ContainerContextMenu.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//

import SwiftUI
import PortainerKit
import IndicatorsKit
import CommonHaptics

struct ContainerContextMenu: View {
	private typealias Localization = Localizable.ContainerContextMenu

	@EnvironmentObject private var sceneDelegate: SceneDelegate
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.portainerServerURL) private var portainerServerURL: URL?
	@Environment(\.portainerSelectedEndpointID) private var portainerSelectedEndpointID: Endpoint.ID?

	let containerID: Container.ID
	let containerDisplayName: String?
	let containerState: ContainerState?
	let containerStatus: String?
	let containerIsStored: Bool

	init(container: Container) {
		self.containerID = container.id
		self.containerDisplayName = container.displayName
		self.containerState = container.state
		self.containerStatus = container.status
		self.containerIsStored = container.isStored
	}

	@ViewBuilder
	private var resumeButton: some View {
		Button(action: { execute(.unpause) }) {
			Text(ExecuteAction.unpause.label)
			Image(systemName: ExecuteAction.unpause.icon)
		}
	}

	@ViewBuilder
	private var restartButton: some View {
		Button(action: { execute(.restart) }) {
			Text(ExecuteAction.restart.label)
			Image(systemName: ExecuteAction.restart.icon)
		}
	}

	@ViewBuilder
	private var startButton: some View {
		Button(action: { execute(.start) }) {
			Text(ExecuteAction.start.label)
			Image(systemName: ExecuteAction.start.icon)
		}
	}

	@ViewBuilder
	private var pauseButton: some View {
		Button(action: { execute(.pause) }) {
			Text(ExecuteAction.pause.label)
			Image(systemName: ExecuteAction.pause.icon)
		}
	}

	@ViewBuilder
	private var stopButton: some View {
		Button(action: { execute(.stop) }) {
			Text(ExecuteAction.stop.label)
			Image(systemName: ExecuteAction.stop.icon)
		}
	}

	@ViewBuilder
	private var killButton: some View {
		Button(role: .destructive, action: { execute(.kill, haptic: .heavy) }) {
			Text(ExecuteAction.kill.label)
			Image(systemName: ExecuteAction.kill.icon)
		}
	}

	@ViewBuilder
	private var attachButton: some View {
		Button(action: attachAction) {
			Label(Localization.attach, systemImage: "terminal")
		}
		.disabled(containerState != .running)
	}

	var body: some View {
		Label(containerStatus ?? containerState?.rawValue.localizedCapitalized ?? Localization.unknownState, systemImage: containerState.icon)

		if !containerIsStored {
			Divider()

			switch containerState {
				case .created:
					pauseButton
					stopButton
					restartButton
					Divider()
					killButton
				case .running:
					pauseButton
					stopButton
					restartButton
					Divider()
					killButton
				case .paused:
					resumeButton
					stopButton
					restartButton
					Divider()
					killButton
				case .restarting:
					pauseButton
					stopButton
					Divider()
					killButton
				case .removing:
					killButton
				case .exited:
					startButton
				case .dead:
					startButton
				case .none:
					resumeButton
					startButton
					restartButton
					pauseButton
					stopButton
					Divider()
					killButton
			}
		}

		Divider()

		attachButton

		//			if let portainerURL = PortainerURLScheme(address: portainerServerURL)?.containerURL(containerID: container.id, endpointID: portainerSelectedEndpointID) {
		//				Divider()
		//
		//				ShareLink(Localization.sharePortainerURL, item: portainerURL)
		//			}
	}

	private func execute(_ action: PortainerKit.ExecuteAction, haptic hapticStyle: Haptics.HapticStyle = .medium) {
		Haptics.generateIfEnabled(hapticStyle)

		let style: Indicator.Style = .init(subheadlineColor: action.color,
										   subheadlineStyle: .primary,
										   iconColor: action.color,
										   iconStyle: .primary,
										   iconVariants: .fill)
		let indicator: Indicator = .init(id: "ContainerExecuteAction.\(containerID)",
										 icon: action.icon,
										 headline: containerDisplayName ?? Localizable.PortainerKit.Generic.container,
										 subheadline: action.label,
										 dismissType: .automatic,
										 style: style)
		sceneDelegate.indicators.display(indicator)

		Task {
			do {
				try await portainerStore.execute(action, on: containerID)

				//					DispatchQueue.main.async {
				//						container.state = action.expectedState
				//						Portainer.shared.refreshContainerPassthroughSubject.send(container.id)
				//					}

				// try await Portainer.shared.getContainers()
			} catch {
				sceneDelegate.handle(error)
			}
		}
	}

	// TODO: attachAction()
	private func attachAction() {
		print(#function)

		Haptics.generateIfEnabled(.sheetPresentation)

		/*
		 do {
		 Haptics.generateIfEnabled(.light)
		 try Portainer.shared.attach(to: container)
		 sceneState.isContainerConsoleSheetPresented = true
		 } catch {
		 sceneState.handle(error)
		 }
		 */
	}
}
