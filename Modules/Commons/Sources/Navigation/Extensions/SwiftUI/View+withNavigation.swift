//
//  View+withNavigation.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: View+withNavigation (NavigationHandlable)

public extension View {
	/// Returns the source view with added `NavigationHandlable` environment.
	/// - Parameter navigationHandler: Designated ``NavigationHandlable``
	@inlinable @MainActor @ViewBuilder
	func withNavigation<Handler: NavigationHandlable>(handler navigationHandler: Handler) -> some View {
		self
			.environment(\.navigationPath, navigationHandler.navigationPath)
			.environment(navigationHandler)
	}
}

// MARK: View+withNavigation (DeeplinkHandlable)

public extension View {
	/// Returns the source view with added `DeeplinkHandlable` environment and `onOpenURL(_:)` handler.
	/// - Parameter navigationHandler: Designated ``DeeplinkHandlable``
	@inlinable @MainActor @ViewBuilder
	func withNavigation<Handler: DeeplinkHandlable>(handler navigationHandler: Handler) -> some View {
		self
			.environment(\.navigationPath, navigationHandler.navigationPath)
			.environment(navigationHandler)
			.onOpenURL { navigationHandler.handleURL($0) }
	}
}
