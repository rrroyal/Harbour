//
//  IndicatorView.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - IndicatorView

struct IndicatorView: View {
	let indicator: Indicator
	@ObservedObject var model: Indicators

	@State private var isExpanded = false
	@State private var dragOffset: CGSize = .zero
	@State private var timer: Timer?

	private let maxWidth: Double = 300

	private let paddingHorizontal: Double = 18
	private let paddingVertical: Double = 12

	private let backgroundShape: some Shape = RoundedRectangle(cornerRadius: 32, style: .circular)

	private let springAnimation: Animation = .interactiveSpring(response: 0.32, dampingFraction: 0.7, blendDuration: 0.8)

	private let dragInWrongDirectionMultiplier: Double = 0.015
	private let dragThreshold: Double = 30

	private var subheadlineOrExpandedText: String? {
		isExpanded ? indicator.expandedText : indicator.subheadline
	}

	private var dragGesture: some Gesture {
		DragGesture()
			.onChanged {
				dragOffset.width = $0.translation.width * dragInWrongDirectionMultiplier
				dragOffset.height = $0.translation.height < 0 ? $0.translation.height : $0.translation.height * dragInWrongDirectionMultiplier
			}
			.onEnded {
				if $0.translation.height > 0 && indicator.expandedText != nil {
					UIImpactFeedbackGenerator(style: .soft).impactOccurred()
					isExpanded.toggle()
					dragOffset = .zero
				} else if $0.translation.height < dragThreshold {
					model.dismiss(indicator)
				} else {
					withAnimation(springAnimation) {
						dragOffset = .zero
					}
				}
			}
	}

	@ViewBuilder
	private var iconView: some View {
		if let icon = indicator.icon {
			Image(systemName: icon)
				.animation(.easeInOut, value: indicator.icon)
				.font(subheadlineOrExpandedText != nil ? .title3 : .footnote)
				.symbolRenderingMode(indicator.style.iconRenderingMode)
//				.animation(.easeInOut, value: indicator.style.iconRenderingMode)
				.symbolVariant(indicator.style.iconVariants)
				.animation(.easeInOut, value: indicator.style.iconVariants)
				.foregroundStyle(indicator.style.iconStyle)
//				.animation(.easeInOut, value: indicator.style.iconStyle)
				.foregroundColor(indicator.style.iconColor)
				.animation(.easeInOut, value: indicator.style.iconColor)
				.transition(.opacity)
				.id("IndicatorView.Icon.\(indicator.id)")
		}
	}

	@ViewBuilder
	private var headlineLabel: some View {
		Text(indicator.headline)
			.animation(.easeInOut, value: indicator.headline)
			.font(.footnote)
			.fontWeight(.medium)
			.lineLimit(1)
			.foregroundStyle(indicator.style.headlineStyle)
//			.animation(.easeInOut, value: indicator.style.headlineStyle)
			.foregroundColor(indicator.style.headlineColor)
			.animation(.easeInOut, value: indicator.style.headlineColor)
			.transition(.opacity)
			.id("IndicatorView.Headline.\(indicator.id)")
	}

	@ViewBuilder
	private var subheadlineLabel: some View {
		if let subheadline = subheadlineOrExpandedText {
			Text(subheadline)
				.animation(.easeInOut, value: subheadline)
				.font(.footnote)
				.fontWeight(.medium)
				.lineLimit(isExpanded ? nil : 1)
				.foregroundStyle(indicator.style.subheadlineStyle)
//				.animation(.easeInOut, value: indicator.style.subheadlineStyle)
				.foregroundColor(indicator.style.subheadlineColor)
				.animation(.easeInOut, value: indicator.style.subheadlineColor)
				.transition(.opacity)
				.id("IndicatorView.Subheadline.\(indicator.id)")
		}
	}

	var body: some View {
		HStack(spacing: 8) {
			iconView

			VStack {
				headlineLabel

				subheadlineLabel
					.padding(.horizontal, 8)
			}
			.multilineTextAlignment(.center)
			.minimumScaleFactor(0.8)
		}
		.padding(.horizontal, paddingHorizontal)
		.padding(.vertical, paddingVertical)
		.background(.thickMaterial, in: backgroundShape)
		.clipShape(backgroundShape)
		.frame(maxWidth: isExpanded ? nil : maxWidth)
		.animation(springAnimation, value: isExpanded)
		.offset(dragOffset)
		.gesture(dragGesture)
		.optionalTapGesture(indicator.onTap)
		.onChange(of: isExpanded) { _ in
			setupTimer()
		}
		.onChange(of: indicator) { _ in
			setupTimer()
		}
		.onAppear {
			setupTimer()
		}
	}
}

// MARK: - IndicatorView+Identifiable

extension IndicatorView: Identifiable {
	var id: String { indicator.id }
}

// MARK: - IndicatorView+Equatable

extension IndicatorView: Equatable {
	static func == (lhs: IndicatorView, rhs: IndicatorView) -> Bool {
		lhs.indicator.id == rhs.indicator.id &&
		lhs.indicator.headline == rhs.indicator.headline &&
		lhs.indicator.subheadline == rhs.indicator.subheadline &&
		lhs.indicator.icon == rhs.indicator.icon &&
		lhs.indicator.expandedText == rhs.indicator.expandedText
	}
}

// MARK: - IndicatorView+Actions

private extension IndicatorView {
	func setupTimer() {
		timer?.invalidate()

		guard !isExpanded else { return }

		guard case .after(let timeout) = indicator.dismissType else {
			return
		}

		self.timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
			self.model.dismiss(with: indicator.id)
		}
	}
}

// MARK: - Previews

struct IndicatorView_Previews: PreviewProvider {
	static let model = Indicators()

	static var previews: some View {
		Group {
			IndicatorView(indicator: .init(id: "",
										   icon: nil,
										   headline: "Headline",
										   dismissType: .manual),
						  model: model)
				.previewDisplayName("Basic")

			IndicatorView(indicator: .init(id: "",
										   icon: "bolt.fill",
										   headline: "Headline",
										   dismissType: .manual),
						  model: model)
				.previewDisplayName("Icon")

			IndicatorView(indicator: .init(id: "",
										   headline: "Headline",
										   subheadline: "Subheadline",
										   dismissType: .manual),
						  model: model)
				.previewDisplayName("Subheadline")

			IndicatorView(indicator: .init(id: "",
										   icon: "bolt.fill",
										   headline: "Headline",
										   subheadline: "Subheadline",
										   dismissType: .manual),
						  model: model)
				.previewDisplayName("Subheadline with icon")

			IndicatorView(indicator: .init(id: "",
										   icon: "bolt.fill",
										   headline: "Headline",
										   subheadline: "Subheadline",
										   dismissType: .manual,
										   style: .init(subheadlineColor: .red, iconColor: .red)),
						  model: model)
				.previewDisplayName("Full colored")
		}
		.previewLayout(.sizeThatFits)
		.padding()
		.background(Color(uiColor: .systemBackground))
		.environment(\.colorScheme, .light)
	}
}
