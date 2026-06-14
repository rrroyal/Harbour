//
//  PortainerStore+Preview.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

struct PortainerStorePreviewModifier: PreviewModifier {
	typealias Context = PortainerStore

	static func makeSharedContext() async throws -> Context {
		let preferences = Preferences()
		let portainerStore = PortainerStore(preferences: preferences)
		portainerStore.isSetup = true
		portainerStore.endpoints = [.init(id: 0, name: "Endpoint")]
		portainerStore.selectedEndpoint = portainerStore.endpoints.first
		portainerStore.tasksController.endpoints?.cancel()
		portainerStore.tasksController.containers?.cancel()
		portainerStore.tasksController.stacks?.cancel()
		portainerStore.containers = [
			.preview(id: "1", name: "Container1"),
			.preview(id: "2", name: "Container2")
		]
		return portainerStore
	}

	func body(content: Content, context: Context) -> some View {
		content
			.environment(context)
	}
}
