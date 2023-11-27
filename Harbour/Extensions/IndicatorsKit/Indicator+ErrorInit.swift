//
//  Indicator+ErrorInit.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import IndicatorsKit
import SwiftUI

extension Indicator {
	init(error: Error) {
		let title: String
		let subtitle: String
		let expandedText: String?

		if let error = error as? LocalizedError, let failureReason = error.failureReason {
			title = error.localizedDescription
			subtitle = failureReason
			expandedText = error.recoverySuggestion ?? failureReason
		} else {
			title = String(localized: "Indicators.Error")
			subtitle = error.localizedDescription
			expandedText = nil
		}

		self.init(
			id: String(describing: error).hashValue.description,
			title: title.localizedCapitalized,
			subtitle: subtitle.localizedCapitalized,
			expandedText: expandedText,
			style: .error
		)
	}
}
