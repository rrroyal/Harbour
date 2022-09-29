//
//  LandingView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI

// MARK: - LandingView

struct LandingView: View {
	@State private var currentScreen: Screen = .features

	// this doesn't work because of `.tabViewStyle(_:)` 🙃
	/*
	var body: some View {
		TabView(selection: $currentScreen) {
			FeaturesView(continueAction: navigateToSetup)
				.tag(Screen.features)

			SetupView()
				.tag(Screen.setup)
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.animation(.easeInOut, value: currentScreen)
	}
	 */

	var body: some View {
		Group {
			switch currentScreen {
				case .features:
					FeaturesView(continueAction: navigateToSetup)
						.tag(Screen.features)
						.transition(viewAnimation(edge: .leading))
				case .setup:
					SetupView()
						.tag(Screen.setup)
						.transition(viewAnimation(edge: .trailing))
			}
		}
		.animation(.easeInOut, value: currentScreen)
	}
}

// MARK: - LandingView+Actions

private extension LandingView {
	func navigateToSetup() {
		currentScreen = .setup
	}
}

// MARK: - LandingView+Helpers

private extension LandingView {
	func viewAnimation(edge: Edge) -> AnyTransition {
		.asymmetric(insertion: .move(edge: edge), removal: .move(edge: edge)).combined(with: .opacity)
	}
}

// MARK: - LandingView+Screen

extension LandingView {
	enum Screen {
		case features
		case setup
	}
}

// MARK: - Previews

struct LandingView_Previews: PreviewProvider {
	static var previews: some View {
		LandingView()
	}
}
