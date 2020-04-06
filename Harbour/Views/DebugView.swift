//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 22/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

struct DebugView: View {
	@EnvironmentObject var Settings: SettingsModel
	@EnvironmentObject var Containers: ContainersModel
	
	@State var username = ""
	@State var password = ""

	var body: some View {
		List {
			// Auth
			Section(header: Text("Auth")) {
				// Username
				TextField("username", text: $username) {
					print("[!] username set: \"\(self.username)\"")
					self.Containers.username = self.username
					self.username = ""
					self.Settings.loggedIn = true
					self.Containers.getContainers()
					generateHaptic(.success)
				}
			}
				
			// API
			Section(header: Text("API")) {
				// Reset containers data
				Button("Reset container data") {
					self.Containers.containers = []
					generateHaptic(.success)
				}
				
				// Status
				HStack {
					Text("Status")
					Spacer()
					Text(String(describing: Containers.status))
				}
				
				// isReachable
				/* HStack {
					Text("Reachable")
					Spacer()
					Text(String(describing: Containers.isReachable))
				} */
				
				// Logged in
				HStack {
					Text("Logged in")
					Spacer()
					Text("\(self.Containers.loggedIn ? "true" : "false") / \(self.Settings.loggedIn ? "true" : "false")")
				}
				
				// Endpoint URL
				HStack {
					Text("endpointURL")
					Spacer()
					Text(String(describing: Containers.endpointURL))
				}
				
				// Endpoint ID
				HStack {
					Text("endpointID")
					Spacer()
					Text(String(describing: Containers.selectedEndpointID))
				}
			}
			
			// Containers
			Section(header: Text("Containers")) {
				// Text(String(describing: Containers.containers))
				
				ForEach(Containers.containers) { container in
					Text(String(describing: container))
				}
			}
			
			// Other
			Section(header: Text("Other")) {
				// Force quit
				Button("Force quit") {
					exit(0)
				}
			}
		}
		.listStyle(GroupedListStyle())
		.navigationBarTitle(Text("🤫"))
	}
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
