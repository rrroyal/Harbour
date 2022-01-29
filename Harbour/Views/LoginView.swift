//
//  LoginView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI
import PortainerKit

struct LoginView: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var sceneState: SceneState
	@EnvironmentObject var portainer: Portainer
	
	@State private var endpoint: String = ""
	@State private var username: String = ""
	@State private var password: String = ""
	
	@State private var savePassword: Bool = false
	
	@FocusState private var focusedField: FocusField?
	
	@State private var buttonLabel: String? = nil
	@State private var buttonColor: Color? = nil
	
	@State private var loginTask: Task<Bool, Error>? = nil
	
	@State private var errorTimer: Timer? = nil
	
	var body: some View {
		VStack {
			Spacer()
			
			Text("Log in")
				.font(.largeTitle.bold())
			
			Spacer()
			
			VStack {
				TextField("http://172.17.0.2", text: $endpoint, onEditingChanged: { finished in
					if finished { loginTask?.cancel() }
				}, onCommit: {
					guard !endpoint.isReallyEmpty else { return }
					
					if !endpoint.starts(with: "http") {
						UIDevice.generateHaptic(.selectionChanged)
						endpoint = "https://\(endpoint)"
					}
					
					focusedField = .username
				})
				.keyboardType(.URL)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
				.focused($focusedField, equals: .endpoint)
				
				TextField("garyhost", text: $username, onEditingChanged: { finished in
					if finished { loginTask?.cancel() }
				}, onCommit: {
					guard !username.isEmpty else { return }
					
					UIDevice.generateHaptic(.selectionChanged)
					focusedField = .password
				})
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
				.focused($focusedField, equals: .username)
					
				SecureField("hunter2", text: $password, onCommit: {
					guard endpoint.isReallyEmpty || username.isEmpty || password.isEmpty else { return }
					
					UIDevice.generateHaptic(.light)
					login()
				})
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
				.focused($focusedField, equals: .password)
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
								Text(buttonLabel.localized.capitalizingFirstLetter)
							} else {
								Text("Log in")
							}
						}
						.transition(.opacity)
					}
				}
				.keyboardShortcut(.defaultAction)
				.foregroundColor(.white)
				.buttonStyle(.customPrimary(backgroundColor: buttonColor ?? .accentColor))
				.animation(.easeInOut, value: !(loginTask?.isCancelled ?? true) || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty)
				.animation(.easeInOut, value: buttonColor)
				.disabled(!(loginTask?.isCancelled ?? true) || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty)
				
				Button(action: {
					UIDevice.generateHaptic(.selectionChanged)
					savePassword.toggle()
				}) {
					HStack {
						Image(systemName: savePassword ? "checkmark" : "circle.dashed")
							.symbolVariant(savePassword ? .circle.fill : .none)
							.id("SavePasswordIcon-\(savePassword)")
						
						Text("Save password")
					}
					.font(.callout.weight(.semibold))
					.opacity(savePassword ? 1 : Constants.secondaryOpacity)
				}
				.buttonStyle(.customTransparent)
				.animation(.easeInOut, value: savePassword)
			}
		}
		.padding()
		.animation(.easeInOut, value: buttonLabel)
		.onDisappear {
			errorTimer?.invalidate()
		}
	}
	
	@Sendable
	func login() {
		let url: URL? = {
			guard var components = URLComponents(string: endpoint) else { return nil }
			components.path = components.path.split(separator: "/").joined(separator: "/")	// #HB-8
			return components.url
		}()
		
		guard let url = url else {
			UIDevice.generateHaptic(.error)
			buttonLabel = "Invalid URL"
			buttonColor = .red
			focusedField = .endpoint
			return
		}
		
		focusedField = nil
		
		loginTask?.cancel()
		loginTask = Task {
			do {
				try await portainer.login(url: url, username: username, password: password, savePassword: savePassword)
				
				UIDevice.generateHaptic(.success)
				
				buttonColor = .green
				buttonLabel = "Success!"
				presentationMode.wrappedValue.dismiss()
				
				Task {
					do {
						try await portainer.getEndpoints()
					} catch {
						sceneState.handle(error)
					}
				}
				
				return true
			} catch {
				UIDevice.generateHaptic(.error)
				
				buttonColor = .red
				buttonLabel = error.readableDescription
				
				errorTimer?.invalidate()
				errorTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
					buttonLabel = nil
					buttonColor = nil
				}
				
				throw error
			}
		}
	}
	
	/* func setupLoginHelpMessageTimer() {
		_ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
			self.showLoginHelpMessage = true
		}
	} */
}

extension LoginView {
	enum FocusField {
		case endpoint, username, password
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}
