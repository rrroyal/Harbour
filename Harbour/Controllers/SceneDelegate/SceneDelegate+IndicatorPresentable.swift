//
//  SceneDelegate+IndicatorPresentable.swift
//  Harbour
//
//  Created by royal on 06/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import IndicatorsKit

extension SceneDelegate: IndicatorPresentable {
	@MainActor
	func presentIndicator(_ presentedIndicator: PresentedIndicator) {
		indicators.display(presentedIndicator.indicator)
	}

	@MainActor
	func presentIndicator(_ presentedIndicator: PresentedIndicator, action: (() -> Void)? = nil) {
		var indicator = presentedIndicator.indicator
		if let action {
			indicator.action = .execute(action)
		}
		indicators.display(indicator)
	}
}
