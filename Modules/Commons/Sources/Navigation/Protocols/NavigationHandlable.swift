//
//  NavigationHandlable.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

/// An object that can handle view navigation.
@MainActor
public protocol NavigationHandlable: AnyObject, Observable {
	/// Navigation path for this view stack.
	var navigationPath: NavigationPath { get set }
}
