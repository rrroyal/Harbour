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
	private let tokenPlaceholder: String = "ptr_********************************************"
	// swiftlint:disable:next force_unwrapping
	private let howToLoginURL = URL(string: "https://harbour.shameful.xyz/docs/setup")!

	init() {
		let viewModel = ViewModel()
		self.viewModel = viewModel
	}

	@ViewBuilder
	private var urlTextField: some View {
		TextField(urlPlaceholder, text: $viewModel.url)
			.fontDesign(.monospaced)
			.submitLabel(.next)
			.autocorrectionDisabled()
			#if os(iOS)
			.keyboardType(.URL)
			.autocapitalization(.none)
			#endif
			.labelsHidden()
			.focused($focusedField, equals: .url)
			.onChange(of: viewModel.url) {
				viewModel.cancelLogin()
			}
			.onSubmit {
				viewModel.onURLTextFieldSubmit()
				focusedField = .token
			}
	}

	@ViewBuilder
	private var tokenTextField: some View {
		SecureField(tokenPlaceholder, text: $viewModel.token)
			.fontDesign(.monospaced)
			.submitLabel(.go)
			.submitScope(viewModel.token.isReallyEmpty)
			.autocorrectionDisabled()
			#if os(iOS)
			.keyboardType(.default)
			.autocapitalization(.none)
			#endif
			.labelsHidden()
			.focused($focusedField, equals: .token)
			.onChange(of: viewModel.token) {
				viewModel.cancelLogin()
			}
			.onSubmit {
				guard viewModel.canSubmit else { return }
				Haptics.generateIfEnabled(.light)
				login()
			}
	}

	@ViewBuilder
	private var loginButton: some View {
		Button {
			Haptics.generateIfEnabled(.light)
			login()
		} label: {
			if viewModel.isLoading {
				ProgressView()
					#if os(macOS)
					.controlSize(.small)
					#endif
			} else {
				Group {
					if let buttonLabel = viewModel.buttonLabel {
						Text(buttonLabel)
					} else {
						Text("SetupView.LoginButton.Login")
					}
				}
				.transition(.opacity)
			}
		}
		.keyboardShortcut(.defaultAction)
		.animation(.default, value: viewModel.buttonLabel)
		.animation(.default, value: viewModel.buttonColor)
		.animation(.default, value: viewModel.isLoading)
		.disabled(!viewModel.canSubmit)
	}

	@ViewBuilder
	private var howToLoginButton: some View {
		Link(destination: howToLoginURL) {
			Label("SetupView.HowToLogin", systemImage: "person.fill.questionmark")
		}
	}

	var body: some View {
		Form {
			NormalizedSection {
				urlTextField
			} header: {
				Text("SetupView.URL")
			}

			NormalizedSection {
				tokenTextField
			} header: {
				Text("SetupView.Token")
			}
		}
		.formStyle(.grouped)
		.scrollDisabled(true)
		#if os(iOS)
		.safeAreaInset(edge: .bottom) {
			VStack {
				loginButton
					.buttonStyle(.customPrimary(foregroundColor: .white, backgroundColor: viewModel.buttonColor ?? .accentColor))

				howToLoginButton
					.buttonStyle(.customTransparent)
					.font(.callout)
					.fontWeight(.medium)
			}
			.padding()
		}
		#endif
		.toolbar {
			#if os(macOS)
			ToolbarItem(placement: .primaryAction) {
				loginButton
			}

			ToolbarItem(placement: .destructiveAction) {
				howToLoginButton
					.font(.callout)
					.fontWeight(.medium)
					.foregroundStyle(.accent)
			}
			#endif
		}
		.navigationTitle("SetupView.Title")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.large)
		#endif
		.onDisappear(perform: viewModel.onViewDisappear)
	}
}

// MARK: - SetupView+Actions

private extension SetupView {
	@discardableResult
	func login() -> Task<Void, Never> {
		Task {
			do {
				let success = try await viewModel.login().value
				if success {
					dismiss()
				}
			} catch {
				errorHandler(error)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	SetupView()
}
