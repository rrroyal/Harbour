import SwiftUI

internal extension Indicators {
	struct IndicatorView: View, Identifiable {
		let indicator: Indicator
		@Binding var isExpanded: Bool
		
		let maxWidth: Double = 300
		let padding: Double = 10
		let backgroundShape: some Shape = RoundedRectangle(cornerRadius: 32, style: .circular)
		
		var body: some View {
			HStack {
				if let icon = indicator.icon {
					Image(systemName: icon)
						.font(indicator.subheadline != nil ? .title3 : .footnote)
						.symbolVariant(indicator.style.iconVariants)
						.foregroundStyle(indicator.style.iconStyle)
						.foregroundColor(indicator.style.iconColor)
						.animation(.easeInOut, value: indicator.style.iconColor)
						.transition(.opacity)
				}
				
				VStack {
					Text(indicator.headline)
						.font(.footnote)
						.fontWeight(.medium)
						.lineLimit(1)
						.foregroundStyle(indicator.style.headlineStyle)
						.foregroundColor(indicator.style.headlineColor)
						.animation(.easeInOut, value: indicator.style.headlineColor)
					
					if let subheadline = isExpanded ? indicator.expandedText : indicator.subheadline {
						Text(subheadline)
							.font(.footnote)
							.fontWeight(.medium)
							.lineLimit(isExpanded ? nil : 1)
							.foregroundStyle(indicator.style.subheadlineStyle)
							.foregroundColor(indicator.style.subheadlineColor)
							.transition(.opacity)
							.animation(.easeInOut, value: indicator.style.subheadlineColor)
							.id("IndicatorViewSubheadline-\(indicator.id)")
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
			.background(.regularMaterial, in: backgroundShape)
			.frame(maxWidth: isExpanded ? nil : maxWidth)
			.animation(.easeInOut, value: indicator.icon)
			.animation(.easeInOut, value: indicator.headline)
//			.animation(.easeInOut, value: isExpanded ? indicator.expandedText : indicator.subheadline)
//			.animation(.interactiveSpring(), value: isExpanded)
			.optionalTapGesture(indicator.onTap)
		}
		
		var id: String { indicator.id }
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
	static let isExpanded: Binding<Bool> = .constant(false)
	
	static var previews: some View {
		Group {
			Indicators.IndicatorView(indicator: .init(id: "", icon: nil, headline: "Headline", dismissType: .manual), isExpanded: isExpanded)
			
			Indicators.IndicatorView(indicator: .init(id: "", icon: "bolt.fill", headline: "Headline", dismissType: .manual), isExpanded: isExpanded)
			
			Indicators.IndicatorView(indicator: .init(id: "", headline: "Headline", subheadline: "Subheadline", dismissType: .manual), isExpanded: isExpanded)
			
			Indicators.IndicatorView(indicator: .init(id: "", icon: "bolt.fill", headline: "Headline", subheadline: "Subheadline", dismissType: .manual), isExpanded: isExpanded)
			
			Indicators.IndicatorView(indicator: .init(id: "", icon: "bolt.fill", headline: "Headline", subheadline: "Subheadline", dismissType: .manual, style: .init(subheadlineColor: .red, iconColor: .red)), isExpanded: isExpanded)
		}
		.padding()
		.background(Color(uiColor: .systemBackground))
		.previewLayout(.sizeThatFits)
		.environment(\.colorScheme, .light)
	}
}
