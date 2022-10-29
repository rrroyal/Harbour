//
//  SceneState+Errors.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import Foundation
import IndicatorsKit

extension SceneState {
	typealias ErrorHandler = (Error, String) -> Void

	func handle(_ error: Error, _debugInfo: String = .debugInfo()) {
		if error is CancellationError {
			logger.debug("Cancelled error: \(error.localizedDescription, privacy: .public) [\(_debugInfo)]")
			return
		}

		logger.error("Error: \(error.localizedDescription, privacy: .public) [\(_debugInfo)]")

		let indicator = Indicator(error: error)
		indicators.display(indicator)
	}
}
