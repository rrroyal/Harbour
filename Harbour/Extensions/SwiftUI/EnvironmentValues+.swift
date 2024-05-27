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

// MARK: - errorHandler

extension EnvironmentValues {
	private struct ErrorHandlerEnvironmentKey: EnvironmentKey {
		static let defaultValue: ErrorHandler = .init { error, _ in
//			assertionFailure("`errorHandler` has been called, but none is attached!")
			os_log(.error, log: .default, "Error: \(error, privacy: .public)")
		}
	}

	/// An action that can handle provided error.
	var errorHandler: ErrorHandler {
		get { self[ErrorHandlerEnvironmentKey.self] }
		set { self[ErrorHandlerEnvironmentKey.self] = newValue }
	}
}

// MARK: - parentShape

extension EnvironmentValues {
	private struct ParentShapeEnvironmentKey: EnvironmentKey {
		static let defaultValue: AnyShape? = nil
	}

	/// Shape of the parent view.
	var parentShape: AnyShape? {
		get { self[ParentShapeEnvironmentKey.self] }
		set { self[ParentShapeEnvironmentKey.self] = newValue }
	}
}

// MARK: - presentIndicator

extension EnvironmentValues {
	private struct PresentIndicatorEnvironmentKey: EnvironmentKey {
		static let defaultValue: PresentIndicatorAction = .init { indicator, _ in
			assertionFailure("`showIndicator` has been called, but none is attached! Indicator: \(indicator)")
		}
	}

	/// An action that presents a provided indicator.
	var presentIndicator: PresentIndicatorAction {
		get { self[PresentIndicatorEnvironmentKey.self] }
		set { self[PresentIndicatorEnvironmentKey.self] = newValue }
	}
}
