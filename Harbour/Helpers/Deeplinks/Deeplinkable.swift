//
//  Deeplinkable.swift
//  Harbour
//
//  Created by royal on 18/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import SwiftUI

protocol Deeplinkable {
	/// Main item navigating to this object.
	associatedtype NavigationItem: NavigableItem

	/// Subdestinations available for this object.
	associatedtype Subdestination

	/// Deeplink destination for this object.
	var destination: HarbourDeeplink.Destination { get }

	@MainActor
	/// Handles the navigation for this object.
	/// - Parameters:
	///   - navigationPath: Root `NavigationPath`
	///   - deeplink: Deeplink to handle
	static func handleNavigation(_ navigationPath: inout NavigationPath, with deeplink: HarbourDeeplink)
}
