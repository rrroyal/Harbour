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
		let style = Indicator.Style(headlineColor: Color.red, iconColor: Color.red)

		let subheadline: String
		let expandedText: String?
		if error.localizedDescription.count <= 16 {
			subheadline = error.localizedDescription
			expandedText = nil
		} else {
			subheadline = Localizable.Indicators.expandToReadMore
			expandedText = error.localizedDescription
		}

		self.init(id: error.localizedDescription.hashValue.description,
				  headline: Localizable.Generic.error,
				  subheadline: subheadline,
				  expandedText: expandedText,
				  dismissType: .automatic,
				  style: style)
	}
}
