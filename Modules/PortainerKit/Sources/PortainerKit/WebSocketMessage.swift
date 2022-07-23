//
//  WebSocketMessage.swift
//  PortainerKit
//
//  Created by royal on 13/06/2021.
//

import Foundation
import Combine

public typealias WebSocketPassthroughSubject = PassthroughSubject<WebSocketMessage, Error>

public struct WebSocketMessage {
	public enum MessageSource {
		case server, client
	}

	public let message: URLSessionWebSocketTask.Message
	public let source: MessageSource
}
