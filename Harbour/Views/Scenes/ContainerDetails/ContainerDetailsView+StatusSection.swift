//
//  ContainerDetailsView+StatusSection.swift
//  Harbour
//
//  Created by royal on 03/12/2022.
//

import SwiftUI
import PortainerKit

extension ContainerDetailsView {
	struct StatusSection: View {
		private typealias Localization = Localizable.ContainerDetails

		let status: ContainerStatus

		var body: some View {
			Section(Localization.containerState) {
				Label(status.state.rawValue.localizedCapitalized, systemImage: status.state.icon)
					.foregroundColor(status.state.color)
			}

			if status.running {
				Section("Running") {
					BooleanLabel(value: status.running)
				}
			}

			if status.paused {
				Section("Paused") {
					BooleanLabel(value: status.paused)
				}
			}

			if status.restarting {
				Section("Restarting") {
					BooleanLabel(value: status.restarting)
				}
			}

			if status.oomKilled {
				Section("OOM Killed") {
					BooleanLabel(value: status.oomKilled)
				}
			}

			if status.dead {
				Section("Dead") {
					BooleanLabel(value: status.dead)
				}
			}

			if status.pid > 0 {
				Section("PID") {
					MonospaceLabel(value: status.pid.description)
				}
			}

			if let startedAt = status.startedAt, startedAt.timeIntervalSince1970 > 0 {
				Section("Started at") {
					MonospaceLabel(value: startedAt.formatted(.dateTime))
				}
			}

			if let finishedAt = status.finishedAt, finishedAt.timeIntervalSince1970 > 0 {
				Section("Finished at") {
					MonospaceLabel(value: finishedAt.formatted(.dateTime))
				}
			}
		}
	}
}

struct ContainerDetailsView_StatusSection_Previews: PreviewProvider {
	static let status = ContainerStatus(state: .running,
										running: true,
										paused: false,
										restarting: false,
										oomKilled: false,
										dead: false,
										pid: 0,
										error: nil,
										startedAt: nil,
										finishedAt: nil)
	static var previews: some View {
		List {
			ContainerDetailsView.StatusSection(status: status)
		}
	}
}
