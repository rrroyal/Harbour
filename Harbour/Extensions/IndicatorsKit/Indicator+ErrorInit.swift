//
//  Indicator+ErrorInit.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import IndicatorsKit

extension Indicator {
	init(error: Error) {
		let style = Indicator.Style(headlineColor: Color.red, subheadlineColor: Color(uiColor: .secondaryLabel), iconColor: Color.red)
		self.init(id: error.localizedDescription.hashValue.description,
				  headline: Localizable.Generic.error,
				  subheadline: Localizable.Indicators.expandToReadMore,
				  expandedText: error.localizedDescription,
				  dismissType: .automatic,
				  style: style)
	}
}
