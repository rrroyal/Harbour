//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import SwiftUI

class Preferences: ObservableObject {
	public static let shared: Preferences = Preferences()

	@AppStorage(UserDefaults.Key.launchedBefore) public var launchedBefore: Bool = false
	@AppStorage(UserDefaults.Key.displayContainerDismissedPrompt) public var displayContainerDismissedPrompt: Bool = true
	
	public let ud: UserDefaults = UserDefaults.standard

	private init() {}
}
