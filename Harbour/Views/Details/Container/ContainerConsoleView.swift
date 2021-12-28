//
//  ContainerConsoleView.swift
//  Harbour
//
//  Created by royal on 13/06/2021.
//

import SwiftUI
import Combine
import PortainerKit

struct ContainerConsoleView: View {
	@ObservedObject var attachedContainer: Portainer.AttachedContainer
	@Environment(\.sceneErrorHandler) var sceneErrorHandler
		
	init(attachedContainer: Portainer.AttachedContainer) {
		self.attachedContainer = attachedContainer
		self.attachedContainer.errorHandler = sceneErrorHandler
	}

	var body: some View {
		ScrollView {
			LazyVStack {
				if attachedContainer.buffer.isEmpty {
					Text("Attached to \(attachedContainer.container.displayName ?? attachedContainer.container.id)!")
						.foregroundStyle(.secondary)
				} else {
					Text(attachedContainer.buffer)
						.lineLimit(nil)
						.textSelection(.enabled)
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				}
			}
			.font(.system(.footnote, design: .monospaced))
			.padding(.small)
		}
		.animation(.easeInOut, value: attachedContainer.buffer.isEmpty)
		.transition(.opacity)
	}
}
