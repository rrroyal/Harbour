//
//  SetupView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI

// MARK: - SetupView

struct SetupView: View {
	@State private var currentScreen: Screen = .welcome

	var body: some View {
		TabView(selection: $currentScreen) {
			WelcomeView()
				.tag(Screen.welcome)

			LoginView()
				.tag(Screen.login)
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
	}
}

// MARK: - SetupView+Screen

extension SetupView {
	enum Screen {
		case welcome
		case login
	}
}

// MARK: - Previews

struct SetupView_Previews: PreviewProvider {
	static var previews: some View {
		SetupView()
	}
}
