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
		case custom(Any.Type)
		case debug
		case intents(Any.Type)
		case scene
		case settings
		case widgets(Any.Type)
		case view(any View.Type)

		var stringValue: String {
			switch self {
			case .app:
				"App"
			case .background:
				"Background"
			case .custom(let any):
				"\(any)"
			case .debug:
				"Debug"
			case .intents(let appIntent):
				"Intents (\(appIntent))"
			case .scene:
				"Scene"
			case .settings:
				"Settings"
			case .widgets(let widget):
				"Widgets (\(widget))"
			case .view(let view):
				"View (\(view))"
			}
		}
	}
}
