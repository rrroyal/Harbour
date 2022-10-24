//
//  IndicatorsOverlay.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - IndicatorsOverlay

struct IndicatorsOverlay: View {
	static let moveAnimation: Animation = .interpolatingSpring(mass: 0.5, stiffness: 45, damping: 45, initialVelocity: 15)

	@ObservedObject var model: Indicators

	private let baseIndex: Double = 1000
	private let zIndexTransformMultiplier: Double = 0.1
	private let transition: AnyTransition = .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top).combined(with: .opacity))

	var body: some View {
		ZStack(alignment: .top) {
			ForEach(model.activeIndicators) { indicator in
				IndicatorView(indicator: indicator, model: model)
					.equatable()
					.shadow(color: .black.opacity(0.085), radius: 8, x: 0, y: 0)
					.transition(transition)
//					.scaleEffect(scale(for: index), anchor: .center)
//					.zIndex(baseIndex - Double(index))
			}
		}
	}
}

// MARK: - IndicatorsOverlay+Helpers

private extension IndicatorsOverlay {
	func scale(for index: Int) -> CGSize {
		let translated = max(0, 1 - (Double(index) * zIndexTransformMultiplier))
		return CGSize(width: translated, height: translated)
	}
}

// MARK: - Previews

struct IndicatorsOverlay_Previews: PreviewProvider {
	static var previews: some View {
		var model: Indicators {
			let model = Indicators()
			model.display(.init(id: "", icon: nil, headline: "Headline", dismissType: .manual))
			return model
		}

		return Text("")
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			.indicatorOverlay(model: model)
	}
}
