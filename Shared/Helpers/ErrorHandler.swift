//
//  ErrorHandler.swift
//  Harbour
//
//  Created by royal on 07/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

struct ErrorHandler {
	typealias WrappedValue = (Error, _ showIndicator: Bool) -> Void

	let wrappedValue: WrappedValue

	init(_ wrappedValue: @escaping WrappedValue) {
		self.wrappedValue = wrappedValue
	}

	func callAsFunction(_ error: Error, showIndicator: Bool = true) {
		wrappedValue(error, showIndicator)
	}
}
