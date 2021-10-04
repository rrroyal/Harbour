import SwiftUI

public extension View {
	func indicatorOverlay(model: Indicators) -> some View {
		overlay(Indicators.IndicatorsOverlay(model: model))
	}
}
