//
//  Logger+init.swift
//  Harbour
//
//  Created by royal on 04/10/2022.
//

import Foundation
import os.log

public extension Logger {
	/// Convenience initializer with `subsystem` already filled in.
	/// - Parameter category: Category of `Logger`
	@inlinable
	init(category: String) {
		self.init(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
	}
}
