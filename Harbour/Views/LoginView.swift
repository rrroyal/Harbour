//
//  LoginView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct LoginView: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var portainer: Portainer
	
	@State private var endpoint: String = Portainer.shared.endpointURL?.absoluteString ?? ""
	@State private var username: String = ""
	@State private var password: String = ""

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
			
			TextField("garyhost", text: $username)
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)
				
			SecureField("huner2", text: $password)
				.keyboardType(.default)
				.disableAutocorrection(true)
				.autocapitalization(.none)

			Spacer()
			
			Button("Log in", role: nil) {
				UIDevice.current.generateHaptic(.light)
				
				guard let url = URL(string: endpoint) else {
					UIDevice.current.generateHaptic(.error)
					return
				}
				
				let result = await portainer.login(url: url, username: username, password: password)
				switch result {
					case .success():
						UIDevice.current.generateHaptic(.success)
						presentationMode.wrappedValue.dismiss()
					case .failure(let error):
						AppState.shared.handle(error)
						break
				}
			}
			.keyboardShortcut(.defaultAction)
			.foregroundColor(.white)
			.buttonStyle(PrimaryButtonStyle())
		}
		.padding()
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}
