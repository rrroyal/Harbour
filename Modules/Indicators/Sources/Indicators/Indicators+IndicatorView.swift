import SwiftUI

internal extension Indicators {
	struct IndicatorView: View {
		let indicator: Indicator
		
		let padding: Double = 10
		let backgroundShape: some Shape = RoundedRectangle(cornerRadius: 32, style: .circular)
		
		var body: some View {
			HStack {
				if let icon = indicator.icon {
					Image(systemName: icon)
						.font(indicator.subheadline != nil ? .title3 : .subheadline)
						.symbolVariant(indicator.style.iconVariants)
						.foregroundStyle(indicator.style.iconStyle)
						.foregroundColor(indicator.style.iconColor)
						.animation(.easeInOut, value: indicator.style.iconColor)
						.transition(.opacity)
				}
				
				VStack {
					Text(indicator.headline)
						.font(.subheadline)
						.fontWeight(.medium)
						.lineLimit(1)
						.foregroundStyle(indicator.style.headlineStyle)
						.foregroundColor(indicator.style.headlineColor)
						.animation(.easeInOut, value: indicator.style.headlineColor)
					
					if let subheadline = indicator.subheadline {
						Text(subheadline)
							.font(.subheadline)
							.fontWeight(.medium)
							.lineLimit(1)
							.foregroundStyle(indicator.style.subheadlineStyle)
							.foregroundColor(indicator.style.subheadlineColor)
							.animation(.easeInOut, value: indicator.style.subheadlineColor)
					}
				}
				.padding(.trailing, indicator.icon != nil ? padding : 0)
				.padding(.horizontal, indicator.subheadline != nil ? padding : 0)
				.multilineTextAlignment(.center)
				.minimumScaleFactor(0.8)
				.transition(.opacity)
			}
			.padding(padding)
			.padding(.horizontal, padding)
			// .background(Material.regular, in: backgroundShape)
			.background(backgroundShape.fill(Color(uiColor: .secondarySystemGroupedBackground)).shadow(color: Color.black.opacity(0.075), radius: 16, x: 0, y: 0))
			.animation(.easeInOut, value: indicator.icon)
			.animation(.easeInOut, value: indicator.headline)
			.animation(.easeInOut, value: indicator.subheadline)
			.optionalTapGesture(indicator.onTap)
		}
	}
}

private extension View {
	@ViewBuilder
	func optionalTapGesture(_ action: (() -> Void)?) -> some View {
		if let action = action {
			onTapGesture(perform: action)
		} else {
			self
		}
	}
}


struct IndicatorView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			Indicators.IndicatorView(indicator: .init(id: "", icon: nil, headline: "Headline", dismissType: .manual))
			
			Indicators.IndicatorView(indicator: .init(id: "", icon: "bolt.fill", headline: "Headline", dismissType: .manual))
			
			Indicators.IndicatorView(indicator: .init(id: "", headline: "Headline", subheadline: "Subheadline", dismissType: .manual))
			
			Indicators.IndicatorView(indicator: .init(id: "", icon: "bolt.fill", headline: "Headline", subheadline: "Subheadline", dismissType: .manual))
			
			Indicators.IndicatorView(indicator: .init(id: "", icon: "bolt.fill", headline: "Headline", subheadline: "Subheadline with action", dismissType: .manual, onTap: { }))
			
			Indicators.IndicatorView(indicator: .init(id: "", icon: "bolt.fill", headline: "Headline", subheadline: "Subheadline", dismissType: .manual, style: .init(subheadlineColor: .red, iconColor: .red)))
		}
		.padding()
		.background(Color(uiColor: .systemBackground))
		.previewLayout(.sizeThatFits)
		.environment(\.colorScheme, .light)
	}
}
