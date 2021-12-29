//
//  AppState+UserActivity.swift
//  Harbour
//
//  Created by royal on 22/10/2021.
//

import Foundation

extension AppState {
	enum UserActivity {
		static let viewingContainer = "\(Bundle.main.bundleIdentifier!).ViewingContainer"
		static let attachedToContainer = "\(Bundle.main.bundleIdentifier!).AttachedToContainer"
		
		static let containerIDKey = "ContainerID"
		static let endpointIDKey = "EndpointID"
	}
}
