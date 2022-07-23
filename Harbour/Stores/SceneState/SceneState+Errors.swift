//
//  SceneState+Errors.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import Foundation
import Indicators

extension SceneState {
	func handle(_ error: Error, _fileID: StaticString = #fileID, _line: Int = #line) {
		logger.error("\(String(describing: error)) [\(_fileID):\(_line)]")

		let indicator = Indicator(error: error)
		indicators.display(indicator)
	}
}
