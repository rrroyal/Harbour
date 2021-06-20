//
//  Portainer+AttachedContainer.swift
//  Harbour
//
//  Created by royal on 13/06/2021.
//

import Combine
import Foundation
import os.log
import PortainerKit
import AppNotifications

extension Portainer {
	class AttachedContainer: ObservableObject {
		public let container: PortainerKit.Container
		public let messagePassthroughSubject: PortainerKit.WebSocketPassthroughSubject
		
		@Published public private(set) var attributedString: AttributedString = ""
		
		private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "Harbour").Portainer.AttachedContainer", category: "AttachedContainer")
		private var messageCancellable: AnyCancellable? = nil
		
		public init(container: PortainerKit.Container, messagePassthroughSubject: PortainerKit.WebSocketPassthroughSubject) {
			self.logger.info("Attached to container with ID \(container.id)")
			self.container = container
			self.messagePassthroughSubject = messagePassthroughSubject
						
			self.messageCancellable = messagePassthroughSubject
				.filter {
					if let result = try? $0.get() { return result.source == .server }
					return true
				}
				.sink(receiveCompletion: passthroughSubjectCompletion, receiveValue: passthroughSubjectValue)
		}
		
		deinit {
			messageCancellable?.cancel()
			logger.info("Deinitialized")
		}
		
		private func passthroughSubjectCompletion(completion: Subscribers.Completion<Error>) {
			switch completion {
				case .finished:
					let string = "Session ended."
					update(string)
				case .failure(let error):
					let string = "Session ended, reason: \(String(describing: error))"
					update(string)
					AppState.shared.handle(error)
			}
		}
		
		private func passthroughSubjectValue(result: Result<PortainerKit.WebSocketMessage, Error>) {
			switch result {
				case .success(let message):
					switch message.message {
						case .string(let string):
							update(string)
						case .data(let data):
							update(String(describing: data))
						@unknown default:
							let string = "Unhandled WebSocketMessage: \(String(describing: result))"
							update(string)
							logger.debug("\(string)")
					}
				case .failure(let error):
					update(String(describing: error))
					
					let notification: AppNotifications.Notification = .init(id: "ContainerWebSocketDisconnected-\(container.id)", dismissType: .timeout(10), icon: "bolt", title: "WebSocket disconnected", description: error.localizedDescription, backgroundStyle: .material(.regular))
					AppState.shared.handle(error, notification: notification)
			}
		}
	
		private func update(_ string: String) {
			let attributedString: AttributedString = AttributedString(string)
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.attributedString.append(attributedString)
			}
		}
	}
}
