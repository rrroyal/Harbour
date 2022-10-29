//
//  SetupView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI

// MARK: - SetupView

struct SetupView: View {
	private typealias Localization = Localizable.Setup

	private static let urlPlaceholder: String = "https://172.17.0.2"
	private static let tokenPlaceholder: String = "hunter2"

	@EnvironmentObject private var sceneState: SceneState
	@EnvironmentObject private var portainer: PortainerStore
	@Environment(\.dismiss) private var dismiss: DismissAction

	@State private var url: String = ""
	@State private var token: String = ""

	@State private var buttonLabel: String?
	@State private var buttonColor: Color?

	@State private var isLoading = false
	@State private var loginTask: Task<Void, Error>?
	@State private var errorTimer: Timer?

	@FocusState private var focusedField: FocusedField?

	private var canSubmit: Bool {
		!isLoading && !url.isReallyEmpty && !token.isReallyEmpty
	}

	@ViewBuilder
	private var urlTextField: some View {
		TextField(Self.urlPlaceholder, text: $url, onEditingChanged: { finished in
			if finished { loginTask?.cancel() }
		})
		.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
		.keyboardType(.URL)
		.submitLabel(.next)
		.disableAutocorrection(true)
		.autocapitalization(.none)
		.focused($focusedField, equals: .url)
		.onSubmit {
			if !url.isReallyEmpty && !url.starts(with: "http") {
				UIDevice.generateHaptic(.selectionChanged)
				url = "https://\(url)"
			}

			focusedField = .token
		}
	}

	@ViewBuilder
	private var tokenTextField: some View {
		SecureField(Self.tokenPlaceholder, text: $token)
		.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
		.keyboardType(.default)
		.submitLabel(.go)
		.submitScope(token.isReallyEmpty)
		.disableAutocorrection(true)
		.autocapitalization(.none)
		.focused($focusedField, equals: .token)
		.onSubmit {
			guard canSubmit else { return }

			UIDevice.generateHaptic(.light)
			login()
		}
	}

	@ViewBuilder
	private var continueButton: some View {
		Button(action: {
			UIDevice.generateHaptic(.light)
			login()
		}) {
			if isLoading {
				ProgressView()
			} else {
				Group {
					if let buttonLabel {
						Text(NSLocalizedString(buttonLabel, comment: ""))
					} else {
						Text(Localization.Button.login)
					}
				}
				.transition(.opacity)
			}
		}
		.keyboardShortcut(.defaultAction)
		.foregroundColor(.white)
		.buttonStyle(.customPrimary(backgroundColor: buttonColor ?? .accentColor))
		.animation(.easeInOut, value: buttonColor)
		.disabled(!canSubmit)
	}

	var body: some View {
		VStack {
			Spacer()

			Text(Localization.headline)
				.font(.largeTitle.bold())

			Spacer()

			VStack {
				urlTextField
				tokenTextField
			}

			Spacer()

			VStack {
				continueButton

				// swiftlint:disable:next force_unwrapping
				Link(destination: URL(string: "https://harbour.shameful.xyz/docs/setup")!) {
					HStack {
						Image(systemName: "person.fill.questionmark")
						Text(Localization.howToLogin)
					}
					.font(.callout.weight(.medium))
					.padding(.horizontal, .small)
				}
				.buttonStyle(.customTransparent)
			}
		}
		.padding()
		.animation(.easeInOut, value: buttonLabel)
		.animation(.easeInOut, value: buttonColor)
		.animation(.easeInOut, value: isLoading)
		.onDisappear {
			errorTimer?.invalidate()
		}
	}
}

// MARK: - SetupView+Actions

private extension SetupView {
	@MainActor
	func login() {
		loginTask?.cancel()
		loginTask = Task {
			isLoading = true

			do {
				guard let url = URL(string: url) else {
					throw GenericError.invalidURL
				}

				try await portainer.setup(url: url, token: token)

				isLoading = false
				UIDevice.generateHaptic(.success)

				buttonColor = .green
				buttonLabel = Localization.Button.success

				dismiss()
			} catch {
				isLoading = false
				UIDevice.generateHaptic(.error)

				buttonColor = .red
				buttonLabel = error.localizedDescription

				errorTimer?.invalidate()
				errorTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
					DispatchQueue.main.async {
						buttonLabel = nil
						buttonColor = nil
					}
				}

				sceneState.handle(error)

				throw error
			}
		}
	}
}

// MARK: - SetupView+FocusedField {

private extension SetupView {
	enum FocusedField {
		case url, token
	}
}

// MARK: - Previews

struct SetupView_Previews: PreviewProvider {
	static var previews: some View {
		SetupView()
	}
}
