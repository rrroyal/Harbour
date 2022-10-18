//
//  ContainerLogsView.swift
//  Harbour
//
//  Created by royal on 16/10/2022.
//

import SwiftUI

// MARK: - ContainerLogsView

struct ContainerLogsView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.sceneErrorHandler) private var sceneErrorHandler: SceneState.ErrorHandler?

	let item: ContainersView.ContainerNavigationItem

	@State private var logs: String?

	private var textSplit: [(index: Int, text: String)] {
		guard let logs, !logs.isEmpty else { return [] }
		let mapped = logs
			.split(separator: "\n")
			.enumerated()
			.map { ($0, String($1)) }
		return mapped
	}

	var body: some View {
		ScrollView {
			Text(logs ?? "<empty>")
				.foregroundStyle(logs.isReallyEmpty ? .secondary : .primary)
				.padding()
		}
		.task(getLogs)
		.navigationTitle("Logs")
	}
}

// MARK: - ContainerLogsView+Actions

private extension ContainerLogsView {
	@MainActor @Sendable
	func getLogs() async {
		do {
			let logs = try await portainerStore.getLogs(for: item.id)
			self.logs = logs
		} catch {
			sceneErrorHandler?(error, String.debugInfo())
		}
	}
}

// MARK: - Previews

struct ContainerLogsView_Previews: PreviewProvider {
	static let item = ContainersView.ContainerNavigationItem(id: "id", displayName: "DisplayName", endpointID: nil)
	static var previews: some View {
		ContainerLogsView(item: item)
	}
}
