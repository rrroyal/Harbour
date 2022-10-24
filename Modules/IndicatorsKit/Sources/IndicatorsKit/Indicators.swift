//
//  Indicators.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import Foundation
import SwiftUI

public final class Indicators: ObservableObject {
	@Published public private(set) var activeIndicators: [Indicator] = []

	public init() { }

	public func display(_ indicator: Indicator) {
		if let index = activeIndicators.firstIndex(where: { $0.id == indicator.id }) {
			activeIndicators[index] = indicator
		} else {
			withAnimation(IndicatorsOverlay.moveAnimation) {
				activeIndicators.append(indicator)
			}
		}
	}

	@inlinable
	public func dismiss(_ indicator: Indicator) {
		dismiss(with: indicator.id)
	}

	public func dismiss(with id: Indicator.ID) {
		guard let index = activeIndicators.firstIndex(where: { $0.id == id }) else { return }
		withAnimation(IndicatorsOverlay.moveAnimation) {
			_ = activeIndicators.remove(at: index)
		}
	}

	public func dismissAll() {
		withAnimation(IndicatorsOverlay.moveAnimation) {
			activeIndicators.removeAll()
		}
	}
}
