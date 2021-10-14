//
//  PseudoLogger.swift
//  Harbour
//
//  Created by royal on 17/10/2021.
//

import Foundation
import os.log

public var _LOGS: [String] = []

class PseudoLogger {
	let subsystem: String
	let category: String
	
	private let logger: Logger
	
	init(subsystem: String, category: String) {
		self.subsystem = subsystem
		self.category = category
		
		self.logger = Logger(subsystem: subsystem, category: category)
	}
	
	public func log(_ message: String) {
		logger.log("\(message)")
		addToGlobalLogs(message)
	}
	
	public func info(_ message: String) {
		logger.info("\(message)")
		addToGlobalLogs(message)
	}
	
	public func debug(_ message: String) {
		logger.debug("\(message)")
		addToGlobalLogs(message)
	}
	
	public func error(_ message: String) {
		logger.error("\(message)")
		addToGlobalLogs(message)
	}
	
	private func addToGlobalLogs(_ message: String) {
		let str = "(\(category)) \(message)".trimmingCharacters(in: .whitespacesAndNewlines)
		_LOGS.append(str)
	}
}
