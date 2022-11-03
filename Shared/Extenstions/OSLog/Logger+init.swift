//
//  Logger+init.swift
//  Harbour
//
//  Created by royal on 04/10/2022.
//

import Foundation
import OSLog

// MARK: - Logger+Category

public extension Logger {
	enum Category: String {
		case appState = "AppState"
		case sceneState = "SceneState"
		case persistence = "Persistence"
		case portainerStore = "PortainerStore"
		case preferences = "Preferences"
		case containerStateIntentHandler = "ContainerStateIntentHandler"
		case containerStateIntentProvider = "ContainerStateIntentProvider"
	}
}

// MARK: - Logger+init(category:)

public extension Logger {
	/// Convenience initializer with `subsystem` already filled in.
	/// - Parameter category: Category of `Logger`
	@inlinable
	init(category: Category) {
		self.init(subsystem: Bundle.main.bundleIdentifier ?? "", category: category.rawValue)
	}
}
