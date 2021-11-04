//
//  PortainerKit+WebSocketMessage.swift
//  PortainerKit
//
//  Created by royal on 13/06/2021.
//

import Foundation

@available(iOS 15, macOS 12, *)
public extension PortainerKit {
	struct WebSocketMessage {
		public enum MessageSource {
			case server, client
		}
		
		public let message: URLSessionWebSocketTask.Message
		public let source: MessageSource
	}
}
