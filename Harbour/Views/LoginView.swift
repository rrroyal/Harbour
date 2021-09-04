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
	
	@State private var isLoading: Bool = false
	@State private var buttonLabel: String? = nil
	@State private var buttonColor: Color? = nil
	
	@State private var errorTimer: Timer? = nil
	
	var body: some View {
		VStack {
			Spacer()
			
			Text("Log in")
				.font(.largeTitle.bold())
			
			Spacer()
			
			TextField("http://172.17.0.2:9000", text: $endpoint)
				.keyboardType(.URL)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
			
			TextField("garyhost", text: $username)
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))
				
			SecureField("hunter2", text: $password)
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle(fontDesign: .monospaced))

			Spacer()
			
			Button(action: login) {
				if isLoading {
					ProgressView()
				} else {
					if let buttonLabel = buttonLabel {
						Text(LocalizedStringKey(buttonLabel.capitalizingFirstLetter()))
					} else {
						Text("Log in")
					}
				}
			}
			.keyboardShortcut(.defaultAction)
			.foregroundColor(.white)
			.buttonStyle(PrimaryButtonStyle(backgroundColor: buttonColor ?? .accentColor))
			.transition(.opacity)
			.animation(.easeInOut, value: isLoading || endpoint.isReallyEmpty || username.isReallyEmpty || password.isReallyEmpty)
			.animation(.easeInOut, value: buttonLabel)
			.animation(.easeInOut, value: buttonColor)
			.disabled(isLoading || endpoint.isReallyEmpty || username.isReallyEmpty || password.isReallyEmpty)
		}
		.padding()
	}
	
	func login() {
		UIDevice.current.generateHaptic(.light)
		
		guard let url = URL(string: endpoint) else {
			UIDevice.current.generateHaptic(.error)
			buttonLabel = "Invalid URL"
			buttonColor = .red
			return
		}
		
		Task {
			do {
				isLoading = true
				try await portainer.login(url: url, username: username, password: password)
				isLoading = false
				
				UIDevice.current.generateHaptic(.success)
				
				buttonColor = .green
				buttonLabel = "Success!"
				presentationMode.wrappedValue.dismiss()
			} catch {
				UIDevice.current.generateHaptic(.error)
				
				isLoading = false
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
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}
