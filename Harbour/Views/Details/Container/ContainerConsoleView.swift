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
	// @Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var portainer: Portainer

	var body: some View {
		if let attachedContainer = portainer.attachedContainer {
			ConsoleView(attachedContainer: attachedContainer)
		} else {
			Text("how did you get here? ಠ_ಠ")
				.foregroundStyle(.primary)
		}
	}
}

private extension ContainerConsoleView {
	struct ConsoleView: View {
		@ObservedObject var attachedContainer: Portainer.AttachedContainer

		var body: some View {
			ScrollView {
				LazyVStack {
					Text(attachedContainer.attributedString)
						.font(.system(.footnote, design: .monospaced))
						.lineLimit(nil)
						.textSelection(.enabled)
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				}
				.padding(.small)
			}
		}
	}
}
