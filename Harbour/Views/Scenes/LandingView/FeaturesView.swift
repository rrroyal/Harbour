//
//  FeaturesView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import CommonHaptics
import SwiftUI

// MARK: - FeaturesView

struct FeaturesView: View {
	let continueAction: () -> Void

	var body: some View {
		VStack {
			Spacer()

			Text("FeaturesView.Headline AppName:\(Text("AppName").foregroundColor(.accentColor))")
				.font(.largeTitle.bold())
				.multilineTextAlignment(.center)

			Spacer()

			VStack(spacing: 20) {
				FeatureCell(headline: "FeaturesView.Feature1.Title",
							subheadline: "FeaturesView.Feature1.Description",
							icon: "ipad.and.iphone")
//				FeatureCell(headline: "LandingView.Feature2.Title",
//							subheadline: "LandingView.Feature2.Description",
//							icon: "questionmark")
//				FeatureCell(headline: "LandingView.Feature3.Title",
//							subheadline: "LandingView.Feature3.Description",
//							icon: "questionmark")
			}

			Spacer()

			Button("FeaturesView.ContinueButton") {
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

/*
#Preview("FeaturesView") {
		FeaturesView(continueAction: { })
			.previewDisplayName("FeaturesView")
}

#Preview("FeatureCell") {
	FeaturesView.FeatureCell(headline: "Headline", subheadline: "Subheadline", icon: "globe")
		.previewLayout(.sizeThatFits)
		.padding()
		.previewDisplayName("FeatureCell")
}
*/
