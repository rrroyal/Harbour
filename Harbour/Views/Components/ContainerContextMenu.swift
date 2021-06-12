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
		Button(role: .destructive, action: { await execute(.kill) }) {
			Text("Kill")
			Image(systemName: "bolt")
		}
	}
	
	var body: some View {
		Group {
			Label(container.state?.rawValue.capitalizingFirstLetter() ?? "Unknown", systemImage: container.stateSymbol)
			
			Divider()
						
			switch container.state {
				case .created:
					pauseButton
					stopButton
					killButton
				case .running:
					pauseButton
					stopButton
					killButton
				case .paused:
					resumeButton
					stopButton
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
					resumeButton
					startButton
					pauseButton
					stopButton
					killButton
			}
		}
	}
	
	private func execute(_ action: PortainerKit.ExecuteAction) async {
		let result = await Portainer.shared.execute(action, for: container)
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
				AppState.shared.handle(error)
		}
	}
}
