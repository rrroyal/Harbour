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
		let style = Indicator.Style(headlineColor: Color.red, iconColor: Color.red)

		let headline: String
		let subheadline: String
		let expandedText: String?

		if let error = error as? LocalizedError, let failureReason = error.failureReason {
			headline = error.localizedDescription
			subheadline = failureReason
			expandedText = error.recoverySuggestion ?? failureReason
		} else {
			headline = "Indicators.Error"
			subheadline = error.localizedDescription
			expandedText = nil
		}

		self.init(id: String(describing: error).hashValue.description,
				  headline: headline,
				  subheadline: subheadline,
				  expandedText: expandedText,
				  style: style)
	}
}
