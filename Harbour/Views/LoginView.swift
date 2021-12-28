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
	
	@State private var endpoint: String = Preferences.shared.endpointURL ?? ""
	@State private var username: String = ""
	@State private var password: String = ""
	
	@State private var savePassword: Bool = false
	
	@FocusState private var focusedField: FocusField?
	@State private var loading: Bool = false
	
	@State private var buttonLabel: String? = nil
	@State private var buttonColor: Color? = nil
	
	@State private var errorTimer: Timer? = nil
	
	var body: some View {
		VStack {
			Spacer()
			
			Text("Log in")
				.font(.largeTitle.bold())
			
			Spacer()
			
			VStack {
				TextField("http://172.17.0.2", text: $endpoint, onCommit: {
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
				
				TextField("garyhost", text: $username, onCommit: {
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
					guard !(loading || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty) else { return }
					
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
					if loading {
						ProgressView()
					} else {
						Group {
							if let buttonLabel = buttonLabel {
								Text(buttonLabel.localized.capitalizingFirstLetter())
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
				.animation(.easeInOut, value: loading || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty)
				.animation(.easeInOut, value: buttonColor)
				.disabled(loading || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty)
				
				Button(action: {
					UIDevice.generateHaptic(.selectionChanged)
					savePassword.toggle()
				}) {
					HStack {
						Image(systemName: savePassword ? "checkmark" : "circle.dashed")
							.symbolVariant(savePassword ? .circle.fill : .none)
							.id("SavePasswordIcon:\(savePassword)")
						
						Text("Save password")
					}
					.font(.callout.weight(.semibold))
					.opacity(savePassword ? 1 : Globals.Views.secondaryOpacity)
				}
				.buttonStyle(.customTransparent)
				.animation(.easeInOut, value: savePassword)
				.padding(.leading)
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
		
		Task {
			do {
				loading = true
				try await portainer.login(url: url, username: username, password: password, savePassword: savePassword)
				
				UIDevice.generateHaptic(.success)
				
				loading = false
				buttonColor = .green
				buttonLabel = "Success!"
				presentationMode.wrappedValue.dismiss()
				
				do {
					try await portainer.getEndpoints()
				} catch {
					sceneState.handle(error)
				}
			} catch {
				UIDevice.generateHaptic(.error)
				
				loading = false
				buttonColor = .red
				if let error = error as? PortainerKit.APIError {
					buttonLabel = error.description
				} else {
					buttonLabel = error.localizedDescription
				}
				
				errorTimer?.invalidate()
				errorTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
					buttonLabel = nil
					buttonColor = nil
				}
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
