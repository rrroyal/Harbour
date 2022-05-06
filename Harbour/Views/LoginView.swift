//
//  LoginView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI
import PortainerKit

struct LoginView: View {
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var sceneState: SceneState
	@EnvironmentObject var portainer: Portainer

	@State private var url: String = ""
	@State private var token: String = ""

	@State private var buttonLabel: String? = nil
	@State private var buttonColor: Color? = nil

	@State private var loginTask: Task<Bool, Error>? = nil
	@State private var errorTimer: Timer? = nil

	@FocusState private var focusedField: FocusField?

	var body: some View {
		VStack {
			Spacer()
			
			Text(Localization.Login.login)
				.font(.largeTitle.bold())
			
			Spacer()

			VStack {
				TextField("https://172.17.0.2", text: $url, onEditingChanged: { finished in
					if finished { loginTask?.cancel() }
				}, onCommit: {
					guard !url.isReallyEmpty else { return }

					if !url.starts(with: "http") {
						UIDevice.generateHaptic(.selectionChanged)
						url = "https://\(url)"
					}

					focusedField = .token
				})
				.keyboardType(.URL)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
				.focused($focusedField, equals: .endpoint)

				SecureField(Localization.Login.Placeholder.token, text: $token) {
					guard !token.isEmpty else { return }

					UIDevice.generateHaptic(.light)
					login()
				}
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
				.focused($focusedField, equals: .token)
			}

			Spacer()

			VStack {
				Button(action: {
					UIDevice.generateHaptic(.light)
					login()
				}) {
					if !(loginTask?.isCancelled ?? true) {
						ProgressView()
					} else {
						Group {
							if let buttonLabel = buttonLabel {
								Text(NSLocalizedString(buttonLabel, comment: "").capitalizingFirstLetter())
							} else {
								Text(Localization.Login.login)
							}
						}
						.transition(.opacity)
					}
				}
				.keyboardShortcut(.defaultAction)
				.foregroundColor(.white)
				.buttonStyle(.customPrimary(backgroundColor: buttonColor ?? .accentColor))
//				.animation(.easeInOut, value: !(loginTask?.isCancelled ?? true) || url.isReallyEmpty || token.isReallyEmpty)
				.animation(.easeInOut, value: buttonColor)
				.disabled(!(loginTask?.isCancelled ?? true) || url.isReallyEmpty || token.isReallyEmpty)

				Link(destination: URL(string: "https://harbour.shameful.xyz/docs/setup")!) {
					HStack {
						Image(systemName: "person.fill.questionmark")
						Text(Localization.Login.howToLogin)
					}
					.font(.callout.weight(.medium))
					.padding(.small)
				}
				.buttonStyle(.customTransparent)
			}
		}
		.padding()
		.animation(.easeInOut, value: buttonLabel)
		.onDisappear {
			errorTimer?.invalidate()
		}
	}

	@Sendable
	private func login() {
		loginTask?.cancel()
		loginTask = Task {
			do {
				guard let url = URL(string: url) else {
					throw GenericError.invalidURL
				}

				try await portainer.setup(url: url, token: token)

				UIDevice.generateHaptic(.success)

				buttonColor = .green
				buttonLabel = "Success!"
				dismiss()

				Task {
					do {
						if portainer.selectedEndpointID != nil {
							try await portainer.getContainers()
						}
					} catch {
						sceneState.handle(error)
					}
				}

				return true
			} catch {
				UIDevice.generateHaptic(.error)
				loginTask?.cancel()

				buttonColor = .red
				buttonLabel = error.localizedDescription

				errorTimer?.invalidate()
				errorTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
					buttonLabel = nil
					buttonColor = nil
				}

				throw error
			}
		}
	}
}

extension LoginView {
	enum FocusField {
		case endpoint, token
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}
