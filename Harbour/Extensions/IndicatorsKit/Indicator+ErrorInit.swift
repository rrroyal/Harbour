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
		let title = (error as? LocalizedError)?.failureReason ?? String(localized: "Indicators.Error")
		let subtitle = error.localizedDescription

		self.init(
			id: "Error.\(title.hashValue).\(subtitle.hashValue)",
			title: title,
			subtitle: subtitle,
			style: .error
		)
	}
}
