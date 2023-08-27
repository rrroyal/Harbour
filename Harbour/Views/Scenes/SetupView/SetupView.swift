//
//  SetupView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
import SwiftUI

// MARK: - SetupView

struct SetupView: View {
	@Environment(\.dismiss) private var dismiss: DismissAction
	@Environment(\.errorHandler) private var errorHandler

	@State private var viewModel: ViewModel
	@FocusState private var focusedField: ViewModel.FocusedField?

	private let urlPlaceholder: String = "https://172.17.0.2"
	private let tokenPlaceholder: String = "token"
	private let textFieldBackgroundColor = Color.secondaryBackground
	// swiftlint:disable:next force_unwrapping
	private let howToLoginURL = URL(string: "https://harbour.shameful.xyz/docs/setup")!

	init() {
		let viewModel = ViewModel()
		self._viewModel = .init(wrappedValue: viewModel)
	}

	@ViewBuilder
	private var urlTextField: some View {
		TextField(urlPlaceholder, text: $viewModel.url, onEditingChanged: { finished in
			viewModel.onURLTextFieldEditingChanged(finished)
		})
		.textFieldStyle(.rounded(fontDesign: .monospaced, backgroundColor: textFieldBackgroundColor))
		.keyboardType(.URL)
		.submitLabel(.next)
		.disableAutocorrection(true)
		.autocapitalization(.none)
		.focused($focusedField, equals: .url)
		.onSubmit {
			viewModel.onURLTextFieldSubmit()
			focusedField = .token
		}
	}

	@ViewBuilder
	private var tokenTextField: some View {
		SecureField(tokenPlaceholder, text: $viewModel.token)
			.textFieldStyle(.rounded(fontDesign: .monospaced, backgroundColor: textFieldBackgroundColor))
			.keyboardType(.default)
			.submitLabel(.go)
			.submitScope(viewModel.token.isReallyEmpty)
			.disableAutocorrection(true)
			.autocapitalization(.none)
			.focused($focusedField, equals: .token)
			.onSubmit { viewModel.onTokenTextFieldSubmit(dismissAction: dismiss, errorHandler: errorHandler) }
	}

	@ViewBuilder
	private var continueButton: some View {
		Button {
			viewModel.onContinueButtonPress(dismissAction: dismiss, errorHandler: errorHandler)
		} label: {
			if viewModel.isLoading {
				ProgressView()
			} else {
				Group {
					if let buttonLabel = viewModel.buttonLabel {
						Text(LocalizedStringKey(buttonLabel))
					} else {
						Text("SetupView.LoginButton")
					}
				}
				.transition(.opacity)
			}
		}
		.keyboardShortcut(.defaultAction)
		.foregroundColor(.white)
		.buttonStyle(.customPrimary(backgroundColor: viewModel.buttonColor ?? .accentColor))
		.animation(.easeInOut, value: viewModel.buttonColor)
		.disabled(!viewModel.canSubmit)
	}

	var body: some View {
		NavigationView {
			VStack {
				Spacer()

				Text("SetupView.Headline")
					.font(.largeTitle)
					.fontWeight(.bold)

				Spacer()

				VStack {
					urlTextField
					tokenTextField
				}

				Spacer()

				VStack(spacing: 24) {
					continueButton

					Link(destination: howToLoginURL) {
						Label("SetupView.HowToLoginButton", systemImage: "person.fill.questionmark")
							.font(.callout.weight(.medium))
							.padding(.horizontal, 6)
					}
					.buttonStyle(.customTransparent)
				}
			}
			.padding()
			.toolbar {
				#if targetEnvironment(macCatalyst)
				ToolbarItem(placement: .cancellationAction) {
					Button("Generic.Close") {
//						Haptics.generateIfEnabled(.sheetPresentation)
						dismiss()
					}
				}
				#endif
			}
		}
		.background(Color(uiColor: .systemBackground), ignoresSafeAreaEdges: .all)
		.animation(.easeInOut, value: viewModel.buttonLabel)
		.animation(.easeInOut, value: viewModel.buttonColor)
		.animation(.easeInOut, value: viewModel.isLoading)
		.onDisappear(perform: viewModel.onViewDisappear)
	}
}

// MARK: - Previews

#Preview {
	SetupView()
}
