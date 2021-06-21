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
	@EnvironmentObject var portainer: Portainer
	
	@State private var endpoint: String = Portainer.shared.endpointURL ?? ""
	@State private var username: String = ""
	@State private var password: String = ""
	
	@State private var isLoading: Bool = false
	@State private var buttonLabel: String? = nil
	@State private var buttonColor: Color? = nil
	
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
				.textFieldStyle(RoundedTextFieldStyle())
				
			SecureField("hunter2", text: $password)
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				.textFieldStyle(RoundedTextFieldStyle())

			Spacer()
			
			Button(role: nil, action: login) {
				if isLoading {
					ProgressView()
				} else {
					if let buttonLabel = buttonLabel {
						Text(LocalizedStringKey(buttonLabel))
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
	
	func login() async {
		UIDevice.current.generateHaptic(.light)
		
		guard let url = URL(string: endpoint) else {
			UIDevice.current.generateHaptic(.error)
			buttonLabel = "Invalid URL"
			buttonColor = .red
			return
		}
		
		isLoading = true
		let result = await portainer.login(url: url, username: username, password: password)
		isLoading = false
		switch result {
			case .success():
				UIDevice.current.generateHaptic(.success)
				DispatchQueue.main.async {
					buttonLabel = "Success!"
					buttonColor = .green
					presentationMode.wrappedValue.dismiss()
				}
				
			case .failure(let error):
				UIDevice.current.generateHaptic(.error)
				DispatchQueue.main.async {
					if let error = error as? PortainerKit.APIError {
						buttonLabel = error.description
					} else {
						buttonLabel = error.localizedDescription
					}
					buttonColor = .red
				}
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			buttonLabel = nil
			buttonColor = nil
		}
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}
