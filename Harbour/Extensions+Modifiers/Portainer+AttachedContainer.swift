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
	final class AttachedContainer: ObservableObject {
		public let container: PortainerKit.Container
		public let messagePassthroughSubject: PortainerKit.WebSocketPassthroughSubject
		
		public var errorHandler: SceneState.ErrorHandler?
		public internal(set) var endpointID: PortainerKit.Endpoint.ID? = nil
		public private(set) var isConnected: Bool = true
		
		@Published public private(set) var attributedString: AttributedString = ""

		private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Portainer.AttachedContainer")
		private var messageCancellable: AnyCancellable? = nil
		
		public init(container: PortainerKit.Container, messagePassthroughSubject: PortainerKit.WebSocketPassthroughSubject) {
			logger.info("Attached to container with ID \(container.id, privacy: .sensitive(mask: .hash)) [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			
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
			logger.info("Deinitialized [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
			messageCancellable?.cancel()
		}
		
		public func disconnect() {
			isConnected = false
			messageCancellable?.cancel()
		}
		
		private func passthroughSubjectCompletion(_ completion: Subscribers.Completion<Error>) {
			isConnected = false

			update(completion: completion)

			switch completion {
				case .finished:
					break
				case .failure(let error):
					errorHandler?(error, nil, #fileID, #line, #function)
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
							let error = AttachedContainerError.unhandledMessage(String(describing: result))
							update(error)

							logger.warning("Unhandled WebSocketMessage: \(String(describing: result), privacy: .public) [\(#fileID, privacy: .public):\(#line, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public)]")
					}
				case .failure(let error):
					isConnected = false
					update(error)
					
					let indicator: Indicators.Indicator = .init(id: "ContainerWebSocketDisconnected-\(container.id)", icon: "bolt.fill", headline: Localization.Indicator.WebSocketDisconnected.title, subheadline: error.readableDescription, dismissType: .after(5))
					errorHandler?(error, indicator, #fileID, #line, #function)
			}
		}

		private func update(_ string: String) {
			self.attributedString.append(AttributedString(string))
		}

		private func update(completion: Subscribers.Completion<Error>) {
			var attributes = AttributeContainer()

			let string: String
			switch completion {
				case .finished:
					attributes.foregroundColor = .secondaryLabel
					string = Localization.Portainer.AttachedContainer.finished
				case .failure(let error):
					attributes.foregroundColor = .red
					string = error.readableDescription
			}

			let attributedString = AttributedString(string, attributes: attributes)
			self.attributedString.append(attributedString)
		}

		private func update(_ error: Error) {
			var attributes = AttributeContainer()
			attributes.foregroundColor = .red

			let attributedString = AttributedString(error.readableDescription, attributes: attributes)
			self.attributedString.append(attributedString)
		}
	}
}

private extension Portainer.AttachedContainer {
	enum AttachedContainerError: LocalizedError {
		case unhandledMessage(String)

		var errorDescription: String {
			switch self {
				case .unhandledMessage(let message):
					return Localization.Portainer.AttachedContainer.unhandledMessage(message)
			}
		}
	}
}
