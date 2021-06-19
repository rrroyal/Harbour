//
//  ContainerContextMenu.swift
//  Harbour
//
//  Created by royal on 12/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerContextMenu: View {
	let container: PortainerKit.Container
	
	var resumeButton: some View {
		Button(role: nil, action: { await execute(.unpause) }) {
			Text("Resume")
			Image(systemName: "wake")
		}
	}
	
	var startButton: some View {
		Button(role: nil, action: { await execute(.start) }) {
			Text("Start")
			Image(systemName: "play")
		}
	}
	
	var pauseButton: some View {
		Button(role: nil, action: { await execute(.pause) }) {
			Text("Pause")
			Image(systemName: "pause")
		}
	}
	
	var stopButton: some View {
		Button(role: nil, action: { await execute(.stop) }) {
			Text("Stop")
			Image(systemName: "stop")
		}
	}
	
	var killButton: some View {
		Button(role: .destructive, action: { await execute(.kill, haptic: .heavy) }) {
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
				Portainer.shared.attach(to: container)
				AppState.shared.isContainerConsoleViewPresented = true
			}) {
				Label("Attach", systemImage: "terminal")
			}
			.disabled(container.state != .running)
		}
	}
	
	private func execute(_ action: PortainerKit.ExecuteAction, haptic: UIDevice.FeedbackStyle = .medium) async {
		await UIDevice.current.generateHaptic(haptic)
		
		let result = await Portainer.shared.execute(action, on: container)
		switch result {
			case .success():
				DispatchQueue.main.async {
					self.container.state = action.expectedState
					Portainer.shared.refreshCurrentContainer.send()
				}
				
				if let endpointID = Portainer.shared.selectedEndpoint?.id {
					await Portainer.shared.getContainers(endpointID: endpointID)
				}
				
			case .failure(let error):
				await UIDevice.current.generateHaptic(.error)
				AppState.shared.handle(error)
		}
	}
}
