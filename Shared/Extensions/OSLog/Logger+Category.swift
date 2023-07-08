//
//  Logger+Category.swift
//  Harbour
//
//  Created by royal on 04/10/2022.
//

import CommonOSLog
import Foundation
import OSLog

extension Logger {
	enum Category {
		static let app = "App"
		static let background = "Background"
		static let debug = "Debug"
		static let intents = "Intents"
	}
}
