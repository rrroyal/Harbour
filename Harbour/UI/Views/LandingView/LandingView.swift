//
//  LandingView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - LandingView

struct LandingView: View {
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			VStack {
				Spacer(minLength: 20)

				Text("FeaturesView.Headline AppName:\(Text("AppName").foregroundColor(.accentColor))")
					.font(.largeTitle.bold())
					.multilineTextAlignment(.center)
					.padding(.horizontal)

				Spacer(minLength: 20)

				VStack(spacing: 20) {
					FeatureCell(
						headline: "FeaturesView.Feature1.Title",
						subheadline: "FeaturesView.Feature1.Description",
						icon: "command"
					)
					FeatureCell(
						headline: "FeaturesView.Feature2.Title",
						subheadline: "FeaturesView.Feature2.Description",
						icon: SFSymbol.stack
					)
					FeatureCell(
						headline: "FeaturesView.Feature3.Title",
						subheadline: "FeaturesView.Feature3.Description",
						icon: "sparkles.square.filled.on.square"
					)
				}

				Spacer(minLength: 40)

				Group {
					if navigateToSetupOnContinue {
						NavigationLink("FeaturesView.ContinueButton") {
							SetupView {
								dismiss()
							}
							.navigationBarBackButtonHidden()
						}
					} else {
						Button("FeaturesView.ContinueButton") {
							dismiss()
						}
					}
				}
				.buttonStyle(.customPrimary)
			}
			.padding()
		}
	}
}

// MARK: - Helpers

private extension LandingView {
	var navigateToSetupOnContinue: Bool {
		PortainerStore.shared.savedURLs.isEmpty
	}
}

// MARK: - Subviews

private extension LandingView {
	struct FeatureCell: View {
		let headline: LocalizedStringKey
		let subheadline: LocalizedStringKey
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

#Preview {
	LandingView()
}

#Preview("FeatureCell") {
	LandingView.FeatureCell(
		headline: "FeaturesView.Feature1.Title",
		subheadline: "FeaturesView.Feature1.Description",
		icon: "globe"
	)
	.padding()
}
