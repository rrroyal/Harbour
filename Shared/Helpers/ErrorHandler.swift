//
//  ErrorHandler.swift
//  Harbour
//
//  Created by royal on 07/06/2023.
//

import Foundation

struct ErrorHandler: @unchecked Sendable {
	let wrappedValue: (Error, String) -> Void

	init(_ wrappedValue: @escaping (Error, String) -> Void) {
		self.wrappedValue = wrappedValue
	}

	func callAsFunction(_ error: Error, _ debugInfo: String = ._debugInfo()) {
		wrappedValue(error, debugInfo)
	}
}
