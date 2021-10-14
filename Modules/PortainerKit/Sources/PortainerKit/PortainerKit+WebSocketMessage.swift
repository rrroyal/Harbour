//
//  PortainerKit+WebSocketMessage.swift
//  PortainerKit
//
//  Created by royal on 13/06/2021.
//

import Foundation

@available(iOS 14, macOS 11, *)
public extension PortainerKit {
	enum MessageSource {
		case server
		case client
	}

	struct WebSocketMessage {
		public let message: URLSessionWebSocketTask.Message
		public let source: MessageSource
	}
}
