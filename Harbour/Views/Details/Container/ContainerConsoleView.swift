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

		let messagesTextID: String = "MessagesList"

		var body: some View {
			ScrollView {
				ScrollViewReader { scroll in
					LazyVStack {
						Text(attachedContainer.attributedString)
							.font(.system(.footnote, design: .monospaced))
							.lineLimit(nil)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
							.id(messagesTextID)
					}
					.padding(.small)
					.onChange(of: attachedContainer.buffer.count) { _ in
						scroll.scrollTo(messagesTextID, anchor: .bottom)
					}
				}
			}
			.background(Color(uiColor: .systemBackground).edgesIgnoringSafeArea(.all))
		}
	}
}
