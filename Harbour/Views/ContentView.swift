//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 14/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var Containers: ContainersModel
	@EnvironmentObject var Settings: SettingsModel
	
	@State var shouldPresentOnboarding: Bool = !UserDefaults.standard.bool(forKey: "launchedBefore")
	@State var shouldPresentSettings: Bool = false
	@State var selectedView: String? = ""
	
	let timer = Timer.publish(every: UserDefaults.standard.double(forKey: "refreshInterval"), on: .main, in: .common).autoconnect()
	
    var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				if (self.Containers.containers.count > 0) {
					CollectionView(self.Containers.containers, isFullScreen: self.Settings.useFullScreenDashboard) { container in
						NavigationLink(destination: ContainerDetailView(container: container), tag: container.id, selection: self.$selectedView) {
							ContainerCell(container: container)
								.environmentObject(self.Containers)
								.accentColor(.primary)
								// .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.05), lineWidth: container.id == self.selectedView ? 3 : 0))
						}
					}
				} else {
					Text(self.Containers.status)
						.opacity(0.25)
						.id("containerStatus:" + self.Containers.status)
				}
			}
			.padding(.horizontal, 4)
			.transition(.opacity)
			.animation(.easeInOut(duration: 0.25))
			.navigationBarTitle(Text("Dashboard"), displayMode: .automatic)
			.navigationBarItems(
				leading: Button(action: {
					print("[!] Manually refreshing...")
					generateHaptic(.light)
					withAnimation {
						self.Containers.getContainers()
					}
				}) {
					Image(systemName: "arrow.clockwise")
						.font(.system(size: 20))
						.padding(.vertical)
						.padding(.leading, 2)
				},
				trailing: NavigationLink(destination: SettingsView().environmentObject(Containers).environmentObject(Settings), tag: "settings", selection: self.$selectedView) {
					Image(systemName: "gear")
						.font(.system(size: 20))
						.padding([.leading, .vertical])
						.padding(.trailing, 2)
				}
			)
		}
		.dynamicNavigationViewStyle(useFullscreen: self.Settings.useFullScreenDashboard)
		.sheet(isPresented: $shouldPresentOnboarding, onDismiss: {
			generateHaptic(.light)
			UserDefaults.standard.set(true, forKey: "launchedBefore")
		}, content: {
			OnboardingView(isPresented: self.$shouldPresentOnboarding)
				.environmentObject(self.Containers)
		})
		.onAppear {
			if (!self.Containers.loggedIn) {
				return
			}
			
			withAnimation {
				self.Containers.getContainers()
			}
						
			// Cancel timer if Low Power mode is enabled
			if (ProcessInfo.processInfo.isLowPowerModeEnabled) {
				print("[!] Low power mode detected! Cancelling timer.")
				self.timer.upstream.connect().cancel()
			}
			
			// Cancel timer if automaticRefresh is disabled
			if (!self.Settings.automaticRefresh) {
				print("[*] Cancelling timer")
				self.timer.upstream.connect().cancel()
			} else {
				print("[*] Timer is active (\(Int(UserDefaults.standard.double(forKey: "refreshInterval"))))")
			}
		}
		.onReceive(timer) { _ in
			if (!self.Settings.automaticRefresh || !self.Containers.loggedIn) {
				return
			}
			
			print("[*] Automatically refreshing...")
			withAnimation {
				self.Containers.getContainers()
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
		.environmentObject(SettingsModel())
		.environmentObject(ContainersModel())
    }
}
