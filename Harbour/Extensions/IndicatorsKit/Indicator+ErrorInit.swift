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

		let errorLocalizedDescriptionExpandedText = error.localizedDescription.count > 32 ? error.localizedDescription : nil

		if let error = error as? LocalizedError {
			title = error.failureReason ?? String(localized: "Indicators.Error")
			subtitle = error.localizedDescription
			expandedText = error.recoverySuggestion ?? errorLocalizedDescriptionExpandedText
		} else {
			title = String(localized: "Indicators.Error")
			subtitle = error.localizedDescription
			expandedText = errorLocalizedDescriptionExpandedText
		}

		self.init(
			id: "Error.\(title.hashValue).\(subtitle.hashValue)",
			title: title,
			subtitle: subtitle,
			expandedText: expandedText,
			style: .error
		)
	}
}
