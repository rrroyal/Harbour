import SwiftUI

internal extension Indicators {
	struct IndicatorView: View {
		let indicator: Indicator
		@Binding var isExpanded: Bool
		
		let maxWidth: Double = 300
		let padding: Double = 10
		let backgroundShape: some Shape = RoundedRectangle(cornerRadius: 32, style: .circular)
		
		var subheadline: String? {
			guard let subheadline = indicator.subheadline else {
				return nil
			}

			if let expandedText = indicator.expandedText {
				return isExpanded ? expandedText : subheadline
			} else {
				return subheadline
			}
		}
		
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
					
					if let subheadline = subheadline {
						Text(subheadline)
							.font(.footnote)
							.fontWeight(.medium)
							.lineLimit(isExpanded ? nil : 1)
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
			.background(Material.regular, in: backgroundShape)
			// .background(backgroundShape.fill(Color(uiColor: .secondarySystemGroupedBackground)).shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 0))
			.frame(maxWidth: isExpanded ? nil : maxWidth)
			.animation(.easeInOut, value: indicator.icon)
			.animation(.easeInOut, value: indicator.headline)
			// .animation(.easeInOut, value: subheadline)
			// .animation(.easeInOut, value: isExpanded)
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
