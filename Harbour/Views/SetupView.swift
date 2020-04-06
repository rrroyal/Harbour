//
//  SetupView.swift
//  Harbour
//
//  Created by royal on 22/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

struct SetupView: View {
	@EnvironmentObject var Containers: ContainersModel
	@Binding var isPresented: Bool
	@Binding var isParentPresented: Bool
	var hasParent: Bool
	@State var username: String = ""
	@State var password: String = ""
	@State var buttonColor: Color = Color.mainColor
	@State var buttonText: String = "Log in"
	
    var body: some View {
		VStack(alignment: .center) {
			/* Image(systemName: "chevron.compact.down")
				.font(.system(size: 32, weight: .bold))
				.opacity(0.1) */
			
			Spacer()
			
			Text("SETUP_TITLE")
				.font(.largeTitle)
				.bold()
			
			Spacer()
			
			// Endpoint URL
			VStack(alignment: .leading) {
				Text("Endpoint URL")
					.font(.headline)
				TextField("http://172.17.0.2:9000", text: $Containers.endpointURL) {
					var shouldGenerateFeedback: Bool = false
					
					if (!self.Containers.endpointURL.hasPrefix("https://") && !self.Containers.endpointURL.hasPrefix("http://")) {
						self.Containers.endpointURL = "https://\(self.Containers.endpointURL)"
						shouldGenerateFeedback = true
					}
					if (self.Containers.endpointURL.hasSuffix("/")) {
						self.Containers.endpointURL = String(self.Containers.endpointURL.dropLast())
						shouldGenerateFeedback = true
					}
					
					print("[!] Updating endpointURL to \"\(self.Containers.endpointURL)\"")
					if (shouldGenerateFeedback) { generateHaptic(.light) }
				}
				.padding(12)
				.background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.05)))
				.disableAutocorrection(true)
				.keyboardType(.URL)
				.textContentType(.URL)
			}
			.padding()
			
			// Username
			VStack(alignment: .leading) {
				Text("Username")
					.font(.headline)
				TextField("garyhost", text: $username) {
					print("[!] Updating username to \"\(self.username)\"")
				}
				.padding(12)
				.background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.05)))
				.textContentType(.username)
				.disableAutocorrection(true)
			}
			.padding()
			
			// Password
			VStack(alignment: .leading) {
				Text("Password")
					.font(.headline)
				SecureField("hunter2", text: $password) {
					print("[!] Updating password. Length: \(self.password.lengthOfBytes(using: .utf8))B")
				}
				.padding(12)
				.background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.05)))
				.textContentType(.password)
				.disableAutocorrection(true)
			}
			.padding()
			
			Spacer()
			
			Button(action: {
				if (self.Containers.endpointURL == "" || self.username == "" || self.password == "") {
					generateHaptic(.error)
					withAnimation {
						self.buttonColor = Color(UIColor.systemRed)
						self.buttonText = "Fill all fields!"
						DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
							self.buttonColor = Color.mainColor
							self.buttonText = "Log in"
						}
					}
				} else if (!self.Containers.isReachable) {
					generateHaptic(.error)
					withAnimation {
						self.buttonColor = Color.mainColor
						self.buttonText = "No internet connection"
						DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
							self.buttonColor = Color.mainColor
							self.buttonText = "Log in"
						}
					}
				} else {
					print("[!] Auth data received! Logging in...")
					self.Containers.getToken(username: self.username, password: self.password, refresh: true)
					/* DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.Containers.getContainers()
					} */
					generateHaptic(.success)
					self.isParentPresented = false
				}
			}) {
				Text(buttonText)
					.customButton(buttonColor)
			}
			.id("Button:" + buttonText)
			// .disabled((self.Containers.endpointURL == "" || self.username == "" || self.password == "") ? true : false)
			// .opacity((self.Containers.endpointURL == "" || self.username == "" || self.password == "") ? 0.5 : 1)
			// .transition(.opacity)
			
			Text((self.hasParent ? "Go back" : "Nevermind"))
				.font(.callout)
				.bold()
				//.opacity(0.1)
				.padding()
				.onTapGesture {
					// generateHaptic(.light)
					withAnimation {
						self.isPresented = false
					}
				}
		}
		.padding()
		// .background(Rectangle().fill(Color(UIColor.systemBackground)))
		.contentShape(Rectangle())
		.modifier(AdaptsToSoftwareKeyboard())
		.onTapGesture {
			UIApplication.shared.endEditing()
		}
    }
}

/* struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
			.environmentObject(ContainersModel())
			.environmentObject(SettingsModel())
    }
} */
