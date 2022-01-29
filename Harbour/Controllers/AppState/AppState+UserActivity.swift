//
//  AppState+UserActivity.swift
//  Harbour
//
//  Created by royal on 22/10/2021.
//

import Foundation

extension AppState {
	struct UserActivity {
		static let viewContainer = "\(Bundle.main.bundleIdentifier!).ViewContainer"
		static let attachToContainer = "\(Bundle.main.bundleIdentifier!).AttachToContainer"
		
		static let containerIDKey = "ContainerID"
		static let endpointIDKey = "EndpointID"
	}
}
