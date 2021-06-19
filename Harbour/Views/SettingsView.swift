//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct SettingsView: View {
	@EnvironmentObject var portainer: Portainer
	@State private var isLogoutWarningPresented: Bool = false
	@State private var isLoginViewPresented: Bool = false
	
	var portainerSection: some View {
		Section(header: Text("Portainer")) {
			if let endpointURL = portainer.endpointURL {
				Labeled("URL") {
					Text(endpointURL)
				}
			}
			
			if portainer.isLoggedIn {
				Button("Log out", role: .destructive) {
					UIDevice.current.generateHaptic(.warning)
					isLogoutWarningPresented = true
				}
				.alert(isPresented: $isLogoutWarningPresented) {
					Alert(
						title: Text("Are you sure?"),
						primaryButton: .destructive(Text("Yes"), action: {
							UIDevice.current.generateHaptic(.heavy)
							withAnimation { portainer.logOut() }
						}),
						secondaryButton: .cancel()
					)
				}
			} else {
				Button("Log in") {
					UIDevice.current.generateHaptic(.soft)
					isLoginViewPresented = true
				}
			}
		}
		.animation(.easeInOut, value: portainer.isLoggedIn)
		.animation(.easeInOut, value: portainer.endpointURL)
		.transition(.opacity)
	}
	
	var madeWithLove: some View {
		VStack(spacing: 3) {
			Text("Harbour v\(Bundle.main.buildVersion) (#\(Bundle.main.buildNumber))")
				.font(.subheadline.weight(.semibold))
				.foregroundColor(.secondary)
				.opacity(Globals.Views.secondaryOpacity)
			
			Link(destination: URL(string: "https://github.com/rrroyal/Harbour")!) {
				Text("Made with ❤️ (and ☕️) by @rrroyal")
					.font(.subheadline.weight(.semibold))
					.foregroundColor(.secondary)
					.opacity(Globals.Views.secondaryOpacity)
			}
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.padding(.vertical)
	}
	
	var otherSection: some View {
		Section(header: Text("Other"), footer: madeWithLove) {
			NavigationLink("🤫") {
				DebugView()
			}
		}
	}
	
	var body: some View {
		NavigationView {
			Form {
				portainerSection
				otherSection
			}
			.navigationTitle("Settings")
		}
		.sheet(isPresented: $isLoginViewPresented) {
			LoginView()
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
