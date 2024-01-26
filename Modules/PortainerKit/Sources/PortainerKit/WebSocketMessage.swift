//
//  WebSocketMessage.swift
//  PortainerKit
//
//  Created by royal on 13/06/2021.
//  Copyright © 2023 shameful. All rights reserved.
//

import Combine
import Foundation

public typealias WebSocketPassthroughSubject = PassthroughSubject<WebSocketMessage, Error>

public struct WebSocketMessage {
	public enum MessageSource {
		case server, client
	}

	public let message: URLSessionWebSocketTask.Message
	public let source: MessageSource
}
