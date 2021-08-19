//
//  ContainerContextMenu.swift
//  Harbour
//
//  Created by unitears on 12/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerContextMenu: View {
	let container: PortainerKit.Container
	
	var resumeButton: some View {
		Button(action: { execute(.unpause) }) {
			Text("Resume")
			Image(systemName: "wake")
		}
	}
	
	var startButton: some View {
		Button(action: { execute(.start) }) {
			Text("Start")
			Image(systemName: "play")
		}
	}
	
	var pauseButton: some View {
		Button(action: { execute(.pause) }) {
			Text("Pause")
			Image(systemName: "pause")
		}
	}
	
	var stopButton: some View {
		Button(action: { execute(.stop) }) {
			Text("Stop")
			Image(systemName: "stop")
		}
	}
	
	var killButton: some View {
		Button(role: .destructive, action: { execute(.kill, haptic: .heavy) }) {
			Text("Kill")
			Image(systemName: "bolt")
		}
	}
	
	var body: some View {
		Group {
			Label(container.status ?? container.state?.rawValue.capitalizingFirstLetter() ?? "Unknown", systemImage: container.stateSymbol)
			
			Divider()
						
			switch container.state {
				case .created:
					pauseButton
					stopButton
					Divider()
					killButton
				case .running:
					pauseButton
					stopButton
					Divider()
					killButton
				case .paused:
					resumeButton
					stopButton
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
					pauseButton
					stopButton
					Divider()
					killButton
			}
			
			Divider()
			
			Button(action: {
				do {
					UIDevice.current.generateHaptic(.light)
					try Portainer.shared.attach(to: container)
					AppState.shared.isContainerConsoleSheetPresented = true
				} catch {
					AppState.shared.handle(error)
				}
			}) {
				Label("Attach", systemImage: "terminal")
			}
			.disabled(container.state != .running)
		}
	}
	
	private func execute(_ action: PortainerKit.ExecuteAction, haptic: UIDevice.FeedbackStyle = .medium) {
		UIDevice.current.generateHaptic(haptic)

		Task {
			do {
				try await Portainer.shared.execute(action, on: container)
				
				DispatchQueue.main.async {
					container.state = action.expectedState
					Portainer.shared.refreshCurrentContainer.send()
				}
				
				if let endpointID = Portainer.shared.selectedEndpoint?.id {
					try await Portainer.shared.getContainers(endpointID: endpointID)
				}
			} catch {
				AppState.shared.handle(error)
			}
		}
	}
}
