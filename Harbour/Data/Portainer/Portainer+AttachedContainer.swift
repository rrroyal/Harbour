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

extension Portainer {
	class AttachedContainer: ObservableObject {
		public let container: PortainerKit.Container
		public let passthroughSubject: PortainerKit.WebSocketPassthroughSubject
		
		@Published public private(set) var buffer: [String] = []
		@Published public private(set) var attributedString: AttributedString = ""
		
		private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "Harbour").Portainer.AttachedContainer", category: "AttachedContainer")
		private var cancellable: AnyCancellable? = nil
		
		public init(container: PortainerKit.Container, passthroughSubject: PortainerKit.WebSocketPassthroughSubject) {
			self.logger.info("Attached to container with ID \(container.id)")
			self.container = container
			self.passthroughSubject = passthroughSubject
			
			self.cancellable = passthroughSubject
				.filter {
					if let result = try? $0.get() { return result.source == .server }
					return true
				}
				.sink(receiveCompletion: passthroughSubjectCompletion, receiveValue: passthroughSubjectValue)
		}
		
		deinit {
			cancellable?.cancel()
			cancellable = nil
			
			buffer = []
			attributedString = ""
			
			logger.info("Deinitialized")
		}
		
		private func passthroughSubjectCompletion(completion: Subscribers.Completion<Error>) {
			switch completion {
				case .finished:
					let string = "Session ended."
					update(string)
					updateBuffer(string)
				case .failure(let error):
					let string = "Session ended, reason: \(String(describing: error))"
					update(string)
					updateBuffer(string)
					AppState.shared.handle(error)
			}
		}
		
		private func passthroughSubjectValue(result: Result<PortainerKit.WebSocketMessage, Error>) {
			switch result {
				case .success(let message):
					switch message.message {
						case .string(let string):
							update(string)
							updateBuffer(string)
						case .data(let data):
							update(String(describing: data))
							updateBuffer(String(describing: data))
						@unknown default:
							let string = "Unhandled WebSocketMessage: \(String(describing: result))"
							update(string)
							updateBuffer(string)
							logger.debug("\(string)")
					}
				case .failure(let error):
					update(String(describing: error))
					updateBuffer(String(describing: error))
					AppState.shared.handle(error)
			}
		}
		
		private func updateBuffer(_ string: String) {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.buffer.append(string)
			}
		}
	
		private func update(_ string: String) {
			print(string.data(using: .utf8)?.base64EncodedString() ?? "")
			let attributedString: AttributedString = AttributedString(string)
			
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.attributedString.append(attributedString)
			}
		}
	}
}
