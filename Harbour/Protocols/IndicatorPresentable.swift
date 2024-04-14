//
//  IndicatorPresentable.swift
//  Harbour
//
//  Created by royal on 11/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import IndicatorsKit

// MARK: - IndicatorPresentable

protocol IndicatorPresentable {
	typealias PresentIndicatorAction = (PresentedIndicator) -> Void

	@MainActor
	var indicators: Indicators { get }

	@MainActor
	func presentIndicator(_ presentedIndicator: PresentedIndicator)
}

// MARK: - IndicatorPresentable+Default

extension IndicatorPresentable {
	@MainActor
	func presentIndicator(_ presentedIndicator: PresentedIndicator) {
		indicators.display(presentedIndicator.indicator)
	}
}
