//
//  SceneDelegate+Errors.swift
//  Harbour
//
//  Created by royal on 19/12/2022.
//

import Foundation
import CommonFoundation
import IndicatorsKit

extension SceneDelegate {
	typealias ErrorHandler = (Error, String) -> Void

	func handleError(_ error: Error, _debugInfo: String = ._debugInfo()) {
		guard !error.isCancellationError else {
			logger.debug("Cancelled error: \(error, privacy: .public) [\(_debugInfo, privacy: .public)]")
			return
		}

		logger.error("Error: \(error, privacy: .public) [\(_debugInfo, privacy: .public)]")

		showIndicator(.error(error))
	}
}
