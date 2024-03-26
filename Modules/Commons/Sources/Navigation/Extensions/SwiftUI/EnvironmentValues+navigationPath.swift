//
//  EnvironmentValues+navigationPath.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

public extension EnvironmentValues {
	private struct NavigationPathEnvironmentKey: EnvironmentKey {
		static let defaultValue = NavigationPath()
	}

	/// `NavigationPath` for this view stack.
	var navigationPath: NavigationPath {
		get { self[NavigationPathEnvironmentKey.self] }
		set { self[NavigationPathEnvironmentKey.self] = newValue }
	}
}
