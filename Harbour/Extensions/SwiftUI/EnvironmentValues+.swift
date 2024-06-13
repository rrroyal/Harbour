//
//  EnvironmentValues+.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import IndicatorsKit
import KeychainKit
import OSLog
import SwiftUI

extension EnvironmentValues {
	/// An action that can handle provided error.
	@Entry
	var errorHandler: ErrorHandler = .init { error, _ in
		os_log(.error, log: .default, "Error: \(error, privacy: .public)")
	}

	/// Shape of the parent view.
	@Entry
	var parentShape: AnyShape? = nil

	/// An action that presents a provided indicator.
	@Entry
	var presentIndicator: PresentIndicatorAction = .init { indicator, _ in
		assertionFailure("`showIndicator` has been called, but none is attached! Indicator: \(indicator)")
	}
}
