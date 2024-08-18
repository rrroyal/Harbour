//
//  BackgroundHelper+TaskIdentifier.swift
//  Harbour
//
//  Created by royal on 03/02/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonFoundation
import Foundation

// swiftlint:disable force_unwrapping

extension BackgroundHelper {
	enum TaskIdentifier {
		static let backgroundRefresh = "\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!).BackgroundRefresh"
	}
}

// swiftlint:enable force_unwrapping
