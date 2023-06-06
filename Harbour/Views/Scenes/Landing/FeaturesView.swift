//
//  FeaturesView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI
import CommonHaptics

// MARK: - FeaturesView

struct FeaturesView: View {
	private typealias Localization = Localizable.LandingView

	let continueAction: () -> Void

	var body: some View {
		VStack {
			Spacer()

			Text("\(Localization.titlePrefix) \(Text(Localizable.appName).foregroundColor(.accentColor))!")
				.font(.largeTitle.bold())
				.multilineTextAlignment(.center)

			Spacer()

			VStack(spacing: 20) {
				FeatureCell(headline: Localization.Feature1.title,
							subheadline: Localization.Feature1.description,
							icon: "ipad.and.iphone")
				FeatureCell(headline: Localization.Feature2.title,
							subheadline: Localization.Feature2.description,
							icon: "questionmark")
				FeatureCell(headline: Localization.Feature3.title,
							subheadline: Localization.Feature3.description,
							icon: "questionmark")
			}

			Spacer()

			Button(Localization.continueButton) {
				Haptics.generateIfEnabled(.buttonPress)
				continueAction()
			}
			.buttonStyle(.customPrimary)
		}
		.padding()
	}
}

// MARK: - FeaturesView+FeatureCell

extension FeaturesView {
	struct FeatureCell: View {
		let headline: String
		let subheadline: String
		let icon: String

		let imageWidth: Double = 50

		var body: some View {
			HStack(spacing: 10) {
				Image(systemName: icon)
					.font(.title.weight(.semibold))
					.foregroundStyle(Color.accentColor)
					.symbolVariant(.fill)
					.symbolRenderingMode(.hierarchical)
					.frame(width: imageWidth)

				VStack(alignment: .leading) {
					Text(headline)
						.font(.headline)
						.foregroundStyle(.primary)

					Text(subheadline)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
	}
}

// MARK: - Previews

#Preview("FeaturesView") {
		FeaturesView(continueAction: {})
			.previewDisplayName("FeaturesView")
}

#Preview("FeatureCell") {
	FeaturesView.FeatureCell(headline: "Headline", subheadline: "Subheadline", icon: "globe")
		.previewLayout(.sizeThatFits)
		.padding()
		.previewDisplayName("FeatureCell")
}
