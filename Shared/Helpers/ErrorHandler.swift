//
//  ErrorHandler.swift
//  Harbour
//
//  Created by royal on 07/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

struct ErrorHandler: @unchecked Sendable {
	let wrappedValue: (Error) -> Void

	init(_ wrappedValue: @escaping (Error) -> Void) {
		self.wrappedValue = wrappedValue
	}

	func callAsFunction(_ error: Error) {
		wrappedValue(error)
	}
}
