//
//  WelcomeView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI

// MARK: - WelcomeView

struct WelcomeView: View {

	var body: some View {
		VStack {
			Spacer()

			Text("\(Localizable.Welcome.titlePrefix) \(Text(Localizable.appName).foregroundColor(.accentColor))!")
				.font(.largeTitle.bold())
				.multilineTextAlignment(.center)

			Spacer()

			VStack(spacing: 20) {
				FeatureCell(headline: Localizable.Welcome.Feature1.title,
							subheadline: Localizable.Welcome.Feature1.description,
							icon: "globe")
				FeatureCell(headline: Localizable.Welcome.Feature2.title,
							subheadline: Localizable.Welcome.Feature2.description,
							icon: "globe")
				FeatureCell(headline: Localizable.Welcome.Feature3.title,
							subheadline: Localizable.Welcome.Feature3.description,
							icon: "globe")
			}

			Spacer()

			Button(Localizable.Welcome.continueButton) {
				UIDevice.generateHaptic(.buttonPress)
			}
			.buttonStyle(.customPrimary)
		}
		.padding()
	}
}

// MARK: - WelcomeView+FeatureCell

extension WelcomeView {
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

struct WelcomeView_Previews: PreviewProvider {
	static var previews: some View {
		WelcomeView()
			.previewDisplayName("WelcomeView")

		WelcomeView.FeatureCell(headline: "Headline", subheadline: "Subheadline", icon: "globe")
			.previewLayout(.sizeThatFits)
			.padding()
			.previewDisplayName("FeatureCell")
	}
}
