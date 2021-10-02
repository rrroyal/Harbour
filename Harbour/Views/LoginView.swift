//
//  LoginView.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import SwiftUI
import PortainerKit

struct LoginView: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var portainer: Portainer
	
	@State private var endpoint: String = Preferences.shared.endpointURL ?? ""
	@State private var username: String = ""
	@State private var password: String = ""
	
	@State private var savePassword: Bool = false
	
	@FocusState private var focusedField: FocusField?
	// @State private var showLoginHelpMessage: Bool = false
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
			
			TextField("http://172.17.0.2", text: $endpoint, onCommit: {
				if !endpoint.starts(with: "http") {
					UIDevice.current.generateHaptic(.selectionChanged)
					endpoint = "http://\(endpoint)"
				}
				
				focusedField = .username
			})
			.keyboardType(.URL)
			.disableAutocorrection(true)
			.autocapitalization(.none)
			.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
			.focused($focusedField, equals: .endpoint)
			
			TextField("garyhost", text: $username, onCommit: {
				UIDevice.current.generateHaptic(.selectionChanged)
				focusedField = .password
			})
			.keyboardType(.default)
			.disableAutocorrection(true)
			.autocapitalization(.none)
			.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
			.focused($focusedField, equals: .username)
				
			SecureField("hunter2", text: $password, onCommit: {
				guard !(loading || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty) else { return }
				login()
			})
			.keyboardType(.default)
			.disableAutocorrection(true)
			.autocapitalization(.none)
			.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
			.focused($focusedField, equals: .password)
			
			Spacer()
			
			Button(action: login) {
				if loading {
					ProgressView()
				} else {
					Group {
						if let buttonLabel = buttonLabel {
							Text(NSLocalizedString(buttonLabel, comment: "").capitalizingFirstLetter())
						} else {
							Text("Log in")
						}
					}
					.transition(.opacity)
				}
			}
			.keyboardShortcut(.defaultAction)
			.foregroundColor(.white)
			.buttonStyle(PrimaryButtonStyle(backgroundColor: buttonColor ?? .accentColor))
			.animation(.easeInOut, value: loading || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty)
			.animation(.easeInOut, value: buttonColor)
			.disabled(loading || endpoint.isReallyEmpty || username.isEmpty || password.isEmpty)
			
			Button(action: {
				UIDevice.current.generateHaptic(.selectionChanged)
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
			.buttonStyle(TransparentButtonStyle())
			.animation(.easeInOut, value: savePassword)
			
			/* if showLoginHelpMessage {
				Link(destination: URL(string: "https://harbour.shameful.xyz/docs/setup")!) {
					HStack {
						Image(systemName: "globe")
						Text("Trouble logging in?")
					}
					.font(.callout.weight(.semibold))
					.opacity(Globals.Views.secondaryOpacity)
				}
				.buttonStyle(TransparentButtonStyle())
				.frame(maxWidth: .infinity, alignment: .topTrailing)
			} */
		}
		.padding()
		.animation(.easeInOut, value: buttonLabel)
		// .animation(.easeInOut, value: showLoginHelpMessage)
		// .onAppear(perform: setupLoginHelpMessageTimer)
		.onDisappear {
			errorTimer?.invalidate()
		}
	}
	
	func login() {
		UIDevice.current.generateHaptic(.light)
		
		guard let url = URL(string: endpoint) else {
			UIDevice.current.generateHaptic(.error)
			buttonLabel = "Invalid URL"
			buttonColor = .red
			return
		}
		
		focusedField = nil
		
		Task {
			do {
				loading = true
				try await portainer.login(url: url, username: username, password: password, savePassword: savePassword)
				
				UIDevice.current.generateHaptic(.success)
				
				loading = false
				buttonColor = .green
				buttonLabel = "Success!"
				presentationMode.wrappedValue.dismiss()
				
				do {
					try await portainer.getEndpoints()
				} catch {
					AppState.shared.handle(error)
				}
			} catch {
				UIDevice.current.generateHaptic(.error)
				
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
