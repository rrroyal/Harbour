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
		let indicator: Indicator

		switch presentedIndicator {
		case .error(let error):
			indicator = Indicator(error: error)
		case .copied:
			let style: Indicator.Style = .default
			indicator = Indicator(
				id: presentedIndicator.id,
				icon: SFSymbol.copy,
				title: String(localized: "Indicators.Copied"),
				style: style
			)
		case .containerActionExecuted(let containerID, let containerName, let action):
			let style = Indicator.Style(iconStyle: .primary, tintColor: action.color)
			indicator = .init(
				id: presentedIndicator.id,
				icon: action.icon,
				title: containerName ?? containerID,
				subtitle: action.title,
				style: style
			)
		}

		indicators.display(indicator)
	}
}
