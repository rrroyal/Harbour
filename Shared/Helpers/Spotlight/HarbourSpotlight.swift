//
//  HarbourSpotlight.swift
//  Harbour
//
//  Created by royal on 25/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonOSLog
import CoreSpotlight
import Foundation
import OSLog
import PortainerKit

// MARK: - HarbourSpotlight

enum HarbourSpotlight {
	static let logger = Logger(.custom(HarbourSpotlight.self))
}

// MARK: - HarbourSpotlight+DomainIdentifier

// swiftlint:disable force_unwrapping
extension HarbourSpotlight {
	enum DomainIdentifier {
		static let container = "\(Bundle.main.mainBundleIdentifier!).Container"
		static let stack = "\(Bundle.main.mainBundleIdentifier!).Stack"
	}
}
// swiftlint:enable force_unwrapping

// MARK: - HarbourSpotlight+ItemIdentifier

extension HarbourSpotlight {
	enum ItemIdentifier {
		static func container(id containerID: Container.ID) -> String { "\(DomainIdentifier.container).\(containerID)" }
		static func stack(id stackID: Stack.ID) -> String { "\(DomainIdentifier.stack).\(stackID)" }
	}
}
