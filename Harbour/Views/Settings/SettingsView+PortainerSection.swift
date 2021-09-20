//
//  SettingsView+PortainerSection.swift
//  Harbour
//
//  Created by unitears on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	struct PortainerSection: View {
		@EnvironmentObject var portainer: Portainer
		@EnvironmentObject var preferences: Preferences
		
		@State private var isLoginSheetPresented: Bool = false
		@State private var isLogoutWarningPresented: Bool = false
		
		var loggedInView: some View {
			Button("Log out", role: .destructive) {
				UIDevice.current.generateHaptic(.warning)
				isLogoutWarningPresented = true
			}
			.alert(isPresented: $isLogoutWarningPresented) {
				Alert(title: Text("Are you sure?"),
					  primaryButton: .destructive(Text("Yes"), action: {
					UIDevice.current.generateHaptic(.heavy)
					withAnimation { portainer.logOut() }
				}),
					  secondaryButton: .cancel()
				)
			}
		}
		
		var notLoggedInView: some View {
			Button("Log in") {
				UIDevice.current.generateHaptic(.soft)
				isLoginSheetPresented = true
			}
		}
		
		var body: some View {
			Section(header: Text("Portainer")) {
				/// Endpoint URL
				if let endpointURL = Preferences.shared.endpointURL {
					Labeled(label: "URL", content: endpointURL, monospace: true, lineLimit: 1)
				}
				
				/// Logged in/not logged in label
				if portainer.isLoggedIn {
					loggedInView
				} else {
					notLoggedInView
				}
			}
			.animation(.easeInOut, value: portainer.isLoggedIn)
			.animation(.easeInOut, value: Preferences.shared.endpointURL)
			.transition(.opacity)
			.sheet(isPresented: $isLoginSheetPresented) {
				LoginView()
			}
		}
	}
}
