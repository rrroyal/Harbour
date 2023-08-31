//
//  Logger+.swift
//  Harbour
//
//  Created by royal on 04/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import CommonOSLog
import Foundation
import OSLog
import SwiftUI

// MARK: - Logger+init

extension Logger {
	init(_ category: Logger.Category) {
		self.init(category: category.stringValue)
	}
}

// MARK: - Logger+Category

extension Logger {
	enum Category {
		case app
		case background
		case debug
		case view(any View.Type)
		case widgets(Any.Type)
		case intents(Any.Type)
		case custom(Any.Type)

		var stringValue: String {
			switch self {
			case .app:
				"App"
			case .background:
				"Background"
			case .debug:
				"Debug"
			case .view(let view):
				"View (\(view))"
			case .widgets(let widget):
				"Widgets (\(widget))"
			case .intents(let appIntent):
				"Intents (\(appIntent))"
			case .custom(let any):
				"\(any)"
			}
		}
	}
}
