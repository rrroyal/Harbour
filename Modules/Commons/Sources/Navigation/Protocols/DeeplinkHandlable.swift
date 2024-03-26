//
//  DeeplinkHandlable.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

/// An object that can handle deeplink navigation.
@MainActor
public protocol DeeplinkHandlable: NavigationHandlable {
	/// A function that handles the deeplink navigation.
	func handleURL(_ url: URL)
}
