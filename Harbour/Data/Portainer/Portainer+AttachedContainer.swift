//
//  Portainer+AttachedContainer.swift
//  Harbour
//
//  Created by royal on 13/06/2021.
//

import Combine
import SwiftUI
import Foundation
import os.log
import PortainerKit
import Indicators

extension Portainer {
	class AttachedContainer: ObservableObject {
		public let container: PortainerKit.Container
		public let messagePassthroughSubject: PortainerKit.WebSocketPassthroughSubject
		
		@Published public private(set) var buffer: String = ""
		
		public private(set) var isConnected: Bool = true
		public var errorHandler: SceneState.ErrorHandler?
		
		private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Portainer.AttachedContainer")
		private var messageCancellable: AnyCancellable? = nil
		
		public init(container: PortainerKit.Container, messagePassthroughSubject: PortainerKit.WebSocketPassthroughSubject) {
			logger.info("Attached to container with ID \(container.id)")
			
			self.container = container
			self.messagePassthroughSubject = messagePassthroughSubject
						
			messageCancellable = messagePassthroughSubject
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
		
		private func passthroughSubjectCompletion(_ completion: Subscribers.Completion<Error>) {
			isConnected = false
			
			switch completion {
				case .finished:
					let string = "Session ended."
					update(string)
				case .failure(let error):
					let string = "Session ended, reason: \(String(describing: error))"
					update(string)
					errorHandler?(error, nil, #fileID, #line)
			}
		}
		
		private func passthroughSubjectValue(_ result: Result<PortainerKit.WebSocketMessage, Error>) {
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
					isConnected = false
					update(String(describing: error))
					
					let indicator: Indicators.Indicator = .init(id: "ContainerWebSocketDisconnected-\(container.id)", icon: "bolt.fill", headline: Localization.WEBSOCKET_DISCONNECTED_TITLE.localized, subheadline: error.localizedDescription, dismissType: .after(5))
					errorHandler?(error, indicator, #fileID, #line)
			}
		}
	
		private func update(_ string: String) {
			DispatchQueue.main.async { [weak self] in
				self?.buffer.append(string)
			}
		}
	}
}
