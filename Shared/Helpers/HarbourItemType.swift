//
//  HarbourItemType.swift
//  Harbour
//
//  Created by royal on 09/09/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// swiftlint:disable force_unwrapping

enum HarbourItemType {
	static let container = "\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!).Container"
	static let stack = "\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!).Stack"
}

// swiftlint:enable force_unwrapping
