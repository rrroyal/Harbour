//
//  AppDelegate.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

@MainActor
final class AppDelegate: NSObject {
	var appState: AppState?

	func configure(appState: AppState) {
		self.appState = appState
	}
}
