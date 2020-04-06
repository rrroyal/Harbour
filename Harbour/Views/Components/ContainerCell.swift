//
//  ContainerCell.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

struct ContainerCell: View {
	@EnvironmentObject var Containers: ContainersModel
	var container: Container
	var cellSize: CGFloat {
		if (UIDevice.current.userInterfaceIdiom == .phone) {
			return 80
		} else {
			return 100
		}
	}
	
	var buttonStartString: String = "Start"
	var buttonStartIcon: String = "power"
	var canPause: Bool = true
	var startAction: ContainerAction = .start
	
	init(container: Container) {
		self.container = container
		
		switch (container.state) {
		case .failed:
			buttonStartString = "Start"
			buttonStartIcon = "power"
			startAction = .start
			canPause = false
			break
		case .exited:
			buttonStartString = "Start"
			buttonStartIcon = "power"
			startAction = .start
			canPause = false
			break
		case .paused:
			buttonStartString = "Resume"
			buttonStartIcon = "play.fill"
			startAction = .unpause
			canPause = false
			break
		case .running:
			buttonStartString = "Stop"
			buttonStartIcon = "stop.fill"
			startAction = .stop
			break
		case .runningHealthy:
			buttonStartString = "Stop"
			buttonStartIcon = "stop.fill"
			startAction = .stop
			break
		case .runningUnhealthy:
			buttonStartString = "Stop"
			buttonStartIcon = "stop.fill"
			startAction = .stop
			break
		case .starting:
			buttonStartString = "Stop"
			buttonStartIcon = "stop.fill"
			startAction = .stop
			break
		case .unknown: break
		}
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			// Top row: Status indicator, uptime label
			HStack(alignment: .center) {
				Circle()
					.fill(container.statusColor)
					.frame(width: 10, height: 10)
				Spacer()
				Text(String("\(Date(timeIntervalSince1970: TimeInterval(container.createdAt)).timestampString ?? "?")").uppercased())
					.font(.footnote)
					.bold()
					.scaledToFit()
					.foregroundColor(Color.secondary)
					.lineLimit(1)
					.minimumScaleFactor(0.8)
					.allowsTightening(true)
					// .opacity(0.25)
			}
			
			// Middle
			Spacer()
			
			// Bottom row: Container name
			HStack(alignment: .center) {
				Text(container.name)
					// .font(.headline)
					.bold()
					.scaledToFit()
					.lineLimit(2)
					.minimumScaleFactor(0.7)
					.allowsTightening(true)
				Spacer()
			}
		}
		.frame(width: cellSize, height: cellSize)
		.padding()
		// .background(Color.cellBackground)
		// .mask(RoundedRectangle(cornerRadius: 12))
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.cellBackground))
		.animation(.easeInOut)
		.transition(.opacity)
		.contextMenu {
			// Pause
			if (canPause) {
				Button(action: {
					generateHaptic(.light)
					print("[!] (\(self.container.id)) Pause!")
					self.Containers.performAction(id: self.container.id, action: .pause)
				}) {
					HStack {
						Text("Pause")
						Image(systemName: "pause.fill")
					}
				}
			}
			
			// Start button
			Button(action: {
				generateHaptic(.light)
				print("[!] (\(self.container.id)) \(self.startAction)!")
				self.Containers.performAction(id: self.container.id, action: self.startAction)
			}) {
				HStack {
					Text(buttonStartString)
					Image(systemName: buttonStartIcon)
				}
			}
		}
	}
}


struct ContainerCell_Previews: PreviewProvider {
    static var previews: some View {
		HStack {
			ContainerCell(container: Container(id: "ID", name: "NAME", createdAt: 0, state: .runningHealthy, statusColor: Color(UIColor.systemGreen)))
			// AddContainerCell()
		}
    }
}
