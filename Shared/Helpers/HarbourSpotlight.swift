//
//  HarbourSpotlight.swift
//  Harbour
//
//  Created by royal on 25/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - HarbourSpotlight

enum HarbourSpotlight { }

// MARK: - HarbourSpotlight+DomainIdentifier

// swiftlint:disable force_unwrapping
extension HarbourSpotlight {
	enum DomainIdentifier {
		static var container = "\(Bundle.main.mainBundleIdentifier!).Container"
		static var stack = "\(Bundle.main.mainBundleIdentifier!).Stack"
	}
}
// swiftlint:enable force_unwrapping

// MARK: - HarbourSpotlight+ItemIdentifier

extension HarbourSpotlight {
	enum ItemIdentifier {
		static func container(id containerID: Container.ID) -> String { "\(HarbourSpotlight.DomainIdentifier.container).\(containerID)" }
		static func stack(id stackID: Stack.ID) -> String { "\(HarbourSpotlight.DomainIdentifier.stack).\(stackID)" }
	}
}
