//
//  ContainerLogsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerLogsView: View {
	@EnvironmentObject var portainer: Portainer
	let container: PortainerKit.Container

	@State private var logs: String = ""
	
	@State private var tail: Int = 100
	@State private var displayTimestamps: Bool = false
	
	let tailAmounts: [Int] = [10, 100, 500, 1000, 10_000, 100_000, 1_000_000, 10_000_000]
	
	var toolbarMenu: some View {
		Menu(content: {
			Menu("Lines") {
				ForEach(tailAmounts, id: \.self) { count in
					Button(role: nil, action: {
						tail = count
						await fetch()
					}) {
						Text("\(count)")
						if tail == count {
							Image(systemName: "checkmark")
						}
					}
				}
			}
			
			Button(role: nil, action: {
				displayTimestamps.toggle()
				await fetch()
			}) {
				Text("Timestamps")
				if displayTimestamps {
					Image(systemName: "checkmark")
				}
			}
			
			Divider()
			
			Button(role: nil, action: {
				await fetch()
			}) {
				Label("Refresh", systemImage: "arrow.clockwise")
			}
		}) {
			Image(systemName: "slider.horizontal.3")
		}
	}
	
	var body: some View {
		ScrollView {
			LazyVStack {
				Text(logs)
					.font(.system(.footnote, design: .monospaced))
					.lineLimit(nil)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			}
			.padding(.small)
		}
		.navigationTitle("Logs")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				toolbarMenu
			}
		}
		.task(fetch)
	}
	
	private func fetch() async {
		let result = await portainer.getLogs(from: container, since: 0, tail: tail, displayTimestamps: displayTimestamps)
		switch result {
			case .success(let logs):
				self.logs = logs
			case .failure(let error):
				AppState.shared.handle(error)
		}
	}
}
