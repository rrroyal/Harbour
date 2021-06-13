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
	let containerID: String
	
	@State private var cancellable: AnyCancellable? = nil
	@State private var messages: [String] = []
	
	let messagesTextID: String = "MessagesList"
	
	var body: some View {
		ScrollView {
			ScrollViewReader { scroll in
				LazyVStack {
					Text(messages.joined())
						.font(.system(.footnote, design: .monospaced))
						.lineLimit(nil)
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
						.id(messagesTextID)
				}
				.padding(.small)
				.onChange(of: messages.count) { _ in
					scroll.scrollTo(messagesTextID, anchor: .bottom)
				}
			}
		}
		.task(attachToContainer)
	}
	
	private func attachToContainer() async {
		let result = portainer.attach(to: containerID)
		switch result {
			case .success(let passthroughSubject):
				cancellable = passthroughSubject
					.tryFilter { (try $0.get()).source == .server }
					.sink(receiveCompletion: {
						messages.append(String(describing: $0))
					}, receiveValue: { value in
						handleWebSocketMessage(value)
					})
			case .failure(let error):
				messages.append("Session ended. Reason: \(String(describing: error))")
				AppState.shared.handle(error)
				cancellable = nil
		}
	}
	
	private func handleWebSocketMessage(_ value: Result<PortainerKit.WebSocketMessage, Error>) {
		switch value {
			case .success(let message):
				switch message.message {
					case .string(let string):
						messages.append(string)
					case .data(let data):
						messages.append(String(describing: data))
					@unknown default:
						messages.append("<unhandled case>")
				}
			case .failure(let error):
				messages.append(String(describing: error))
				AppState.shared.handle(error)
		}
	}
}
