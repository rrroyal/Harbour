//
//  ContainerContextMenu.swift
//  Harbour
//
//  Created by royal on 12/06/2021.
//

import SwiftUI
import PortainerKit
import Indicators

struct ContainerContextMenu: View {
	@EnvironmentObject var sceneState: SceneState
	@ObservedObject var container: PortainerKit.Container
	
	var resumeButton: some View {
		Button(action: { execute(.unpause) }) {
			Text(PortainerKit.ExecuteAction.unpause.label)
			Image(systemName: PortainerKit.ExecuteAction.unpause.icon)
		}
	}
	
	var restartButton: some View {
		Button(action: { execute(.restart) }) {
			Text(PortainerKit.ExecuteAction.restart.label)
			Image(systemName: PortainerKit.ExecuteAction.restart.icon)
		}
	}
	
	var startButton: some View {
		Button(action: { execute(.start) }) {
			Text(PortainerKit.ExecuteAction.start.label)
			Image(systemName: PortainerKit.ExecuteAction.start.icon)
		}
	}
	
	var pauseButton: some View {
		Button(action: { execute(.pause) }) {
			Text(PortainerKit.ExecuteAction.pause.label)
			Image(systemName: PortainerKit.ExecuteAction.pause.icon)
		}
	}
	
	var stopButton: some View {
		Button(action: { execute(.stop) }) {
			Text(PortainerKit.ExecuteAction.stop.label)
			Image(systemName: PortainerKit.ExecuteAction.stop.icon)
		}
	}
	
	var killButton: some View {
		Button(role: .destructive, action: { execute(.kill, haptic: .heavy) }) {
			Text(PortainerKit.ExecuteAction.kill.label)
			Image(systemName: PortainerKit.ExecuteAction.kill.icon)
		}
	}
	
	var body: some View {
		Label(container.status ?? container.state?.rawValue.capitalizingFirstLetter() ?? "Unknown", systemImage: container.state.icon)
		
		Divider()
					
		switch container.state {
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
		
		Divider()
		
		Button(action: {
			do {
				UIDevice.generateHaptic(.light)
				try Portainer.shared.attach(to: container)
				sceneState.isContainerConsoleSheetPresented = true
			} catch {
				sceneState.handle(error)
			}
		}) {
			Label("Attach", systemImage: "terminal")
		}
		.disabled(container.state != .running)
	}
	
	private func execute(_ action: PortainerKit.ExecuteAction, haptic: UIDevice.FeedbackStyle = .medium) {
		UIDevice.generateHaptic(haptic)
		
		let style: Indicators.Indicator.Style = .init(subheadlineColor: action.color, subheadlineStyle: .primary, iconColor: action.color, iconStyle: .primary, iconVariants: .fill)
		let indicator: Indicators.Indicator = .init(id: "ContainerActionExecution-\(container.id)", icon: action.icon, headline: container.displayName ?? "Container", subheadline: action.label, dismissType: .after(3), style: style)
		sceneState.indicators.display(indicator)

		Task {
			do {
				try await Portainer.shared.execute(action, on: container)
				
				DispatchQueue.main.async {
					container.state = action.expectedState
					Portainer.shared.refreshContainerPassthroughSubject.send(container.id)
				}
				
				// try await Portainer.shared.getContainers()
			} catch {
				sceneState.handle(error)
			}
		}
	}
}
