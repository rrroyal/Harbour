//
//  FeaturesView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI

// MARK: - FeaturesView

struct FeaturesView: View {
	let continueAction: () -> Void

	var body: some View {
		VStack {
			Spacer()

			Text("\(Localizable.Landing.titlePrefix) \(Text(Localizable.appName).foregroundColor(.accentColor))!")
				.font(.largeTitle.bold())
				.multilineTextAlignment(.center)

			Spacer()

			VStack(spacing: 20) {
				FeatureCell(headline: Localizable.Landing.Feature1.title,
							subheadline: Localizable.Landing.Feature1.description,
							icon: "globe")
				FeatureCell(headline: Localizable.Landing.Feature2.title,
							subheadline: Localizable.Landing.Feature2.description,
							icon: "globe")
				FeatureCell(headline: Localizable.Landing.Feature3.title,
							subheadline: Localizable.Landing.Feature3.description,
							icon: "globe")
			}

			Spacer()

			Button(Localizable.Landing.continueButton) {
				UIDevice.generateHaptic(.buttonPress)
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

struct FeaturesView_Previews: PreviewProvider {
	static var previews: some View {
		FeaturesView(continueAction: {})
			.previewDisplayName("FeaturesView")

		FeaturesView.FeatureCell(headline: "Headline", subheadline: "Subheadline", icon: "globe")
			.previewLayout(.sizeThatFits)
			.padding()
			.previewDisplayName("FeatureCell")
	}
}
