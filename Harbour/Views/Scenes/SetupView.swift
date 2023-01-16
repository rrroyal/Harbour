//
//  SetupView.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI
import CommonFoundation
import CommonHaptics

// MARK: - SetupView

struct SetupView: View {
	private typealias Localization = Localizable.Setup

	@EnvironmentObject private var portainer: PortainerStore
	@Environment(\.dismiss) private var dismiss: DismissAction
	@Environment(\.sceneErrorHandler) private var sceneErrorHandler: SceneDelegate.ErrorHandler?

	@State private var url: String = ""
	@State private var token: String = ""

	@State private var buttonLabel: String?
	@State private var buttonColor: Color?

	@State private var isLoading = false
	@State private var loginTask: Task<Void, Error>?
	@State private var errorTimer: Timer?

	@FocusState private var focusedField: FocusedField?

	private let urlPlaceholder: String = "https://172.17.0.2"
	private let tokenPlaceholder: String = "token"
	private let textFieldBackgroundColor = Color(uiColor: .secondarySystemBackground)

	private var canSubmit: Bool {
		!isLoading && !url.isReallyEmpty && !token.isReallyEmpty
	}

	@ViewBuilder
	private var urlTextField: some View {
		TextField(urlPlaceholder, text: $url, onEditingChanged: { finished in
			if finished { loginTask?.cancel() }
		})
		.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced, backgroundColor: textFieldBackgroundColor))
		.keyboardType(.URL)
		.submitLabel(.next)
		.disableAutocorrection(true)
		.autocapitalization(.none)
		.focused($focusedField, equals: .url)
		.onSubmit {
			if !url.isReallyEmpty && !url.starts(with: "http") {
				Haptics.generateIfEnabled(.selectionChanged)
				url = "https://\(url)"
			}

			focusedField = .token
		}
	}

	@ViewBuilder
	private var tokenTextField: some View {
		SecureField(tokenPlaceholder, text: $token)
			.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced, backgroundColor: textFieldBackgroundColor))
			.keyboardType(.default)
			.submitLabel(.go)
			.submitScope(token.isReallyEmpty)
			.disableAutocorrection(true)
			.autocapitalization(.none)
			.focused($focusedField, equals: .token)
			.onSubmit {
				guard canSubmit else { return }

				Haptics.generateIfEnabled(.light)
				login()
			}
	}

	@ViewBuilder
	private var continueButton: some View {
		Button(action: {
			Haptics.generateIfEnabled(.light)
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
		NavigationView {
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
			.toolbar {
				#if targetEnvironment(macCatalyst)
				ToolbarItem(placement: .cancellationAction) {
					Button(Localizable.Generic.done) {
						Haptics.generateIfEnabled(.sheetPresentation)
						dismiss()
					}
				}
				#endif
			}
		}
		.background(Color(uiColor: .systemBackground), ignoresSafeAreaEdges: .all)
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
				Haptics.generateIfEnabled(.success)

				buttonColor = .green
				buttonLabel = Localization.Button.success

				dismiss()
			} catch {
				isLoading = false
				Haptics.generateIfEnabled(.error)

				buttonColor = .red
				buttonLabel = error.localizedDescription

				errorTimer?.invalidate()
				errorTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
					DispatchQueue.main.async {
						buttonLabel = nil
						buttonColor = nil
					}
				}

				sceneErrorHandler?(error, ._debugInfo())

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
