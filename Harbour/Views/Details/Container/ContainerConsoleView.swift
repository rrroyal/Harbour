//
//  ContainerConsoleView.swift
//  Harbour
//
//  Created by royal on 13/06/2021.
//

import Combine
import PortainerKit
import SwiftUI

struct ContainerConsoleView: View {
	@ObservedObject var attachedContainer: Portainer.AttachedContainer
	
	init(attachedContainer: Portainer.AttachedContainer, sceneErrorHandler: @escaping Portainer.AttachedContainer.ErrorHandler) {
		self.attachedContainer = attachedContainer
		self.attachedContainer.errorHandler = sceneErrorHandler
	}

	var body: some View {
		ScrollView {
			LazyVStack {
				Text(attachedContainer.buffer)
					.font(.system(.footnote, design: .monospaced))
					.lineLimit(nil)
					.textSelection(.enabled)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			}
			.padding(.small)
		}
	}
}
