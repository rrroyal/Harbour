//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

struct IconSettingsView: View {
	@State var currentIcon = UIApplication.shared.alternateIconName ?? "Light"
	
	var body: some View {
		ScrollView {
			VStack {
				ForEach(Bundle.main.appIcons, id: \.self) { icon in
					HStack {
						if (icon == "Light") {
							Image(uiImage: Bundle.main.appIcon ?? UIImage())
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 48, height: 48)
								.mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
						} else {
							Image(uiImage: UIImage(imageLiteralResourceName: "\(icon)@2x.png"))
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 48, height: 48)
								.mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
						}
						
						Text(icon)
							.font(.headline)
						
						Spacer()
						
						if (self.currentIcon == icon) {
							Image(systemName: "checkmark")
								.font(.headline)
						}
					}
					.padding()
					.background(RoundedRectangle(cornerRadius: 12).fill(Color.cellBackground))
					.onTapGesture {
						if (self.currentIcon == icon) {
							return
						}
						
						print("[!] Changing icon to \"\(icon)\"")
						
						self.currentIcon = icon
						generateHaptic(.light)
						
						if (icon == "Light") {
							UIApplication.shared.setAlternateIconName(nil)
						} else {
							UIApplication.shared.setAlternateIconName(icon) { error in
								if let error = error {
									print(error.localizedDescription)
								}
							}
						}
					}
				}
			}
			.padding()
		}
		.navigationBarTitle(Text("Icons"))
	}
}

struct AboutView: View {
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				// About Harbour
				Section(header: Text("ABOUT_ABOUTHARBOUR_TITLE").font(.headline)) {
					Text("ABOUT_ABOUTHARBOUR")
						.padding(.bottom)
				}
				
				// Docker setup
				Section(header: Text("ABOUT_DOCKERSETUP").font(.headline)) {
					Text("ABOUT_DOCKERSETUP_DESCRIPTION")
						.onTapGesture {
							guard let url = URL.init(string: "https://portainer.io") else { return }
							generateHaptic(.light)
							UIApplication.shared.open(url)
						}
						.padding(.bottom)
				}
				
				// About Harbour
				Section(header: Text("ABOUT_ABOUTME_TITLE").font(.headline)) {
					Text("ABOUT_ABOUTME")
						.padding(.bottom)
				}
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
			.padding()
		}
		.navigationBarTitle(Text("About"))
	}
}

struct PrivacyView: View {
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				// Data gathering
				Section(header: Text("PRIVACY_WHATDATA").font(.headline)) {
					Text("PRIVACY_WHATDATA_DESCRIPTION")
						.padding(.bottom)
				}
				
				Text("PRIVACY_DMME").font(.headline)
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
			.padding()
		}
		.navigationBarTitle(Text("Privacy"))
	}
}

struct LegalView: View {
	let AlamofireLicense: String = "The MIT License (MIT)\nCopyright (c) 2014-2020 Alamofire Software Foundation (http://alamofire.org/)\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
	let AlamofireURL: URL? = URL(string: "https://github.com/Alamofire/Alamofire")!
	
	let AlamofireNetworkActivityIndicatorLicense: String = "The MIT License (MIT)\nCopyright (c) 2016 Alamofire Software Foundation (http://alamofire.org/)\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
	let AlamofireNetworkActivityIndicatorURL: URL? = URL(string: "https://github.com/Alamofire/AlamofireNetworkActivityIndicator")!
	
	let SwiftyJSONLicense: String = "The MIT License (MIT)\nCopyright (c) 2017 Ruoyu Fu\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
	let SwiftyJSONURL: URL? = URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!
	
	let KeychainAccessLicense: String = "The MIT License (MIT)\nCopyright (c) 2014 kishikawa katsumi\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
	let KeychainAccessURL: URL? = URL(string: "https://github.com/kishikawakatsumi/KeychainAccess")!
	
	let DrawerViewLicense: String = "The MIT License (MIT)\nCopyright (c) 2019 TotoroQ\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
	let DrawerViewURL: URL? = URL(string: "https://github.com/totoroyyb/DrawerView-SwiftUI")!
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				// Alamofire
				Section(header: Text("Alamofire").font(.headline)) {
					Text(AlamofireLicense)
						.font(.system(size: 14, weight: .regular, design: .monospaced))
						.padding(.bottom)
				}
				.onTapGesture {
					guard let url = self.AlamofireURL else { return }
					generateHaptic(.light)
					UIApplication.shared.open(url)
				}
				
				// AlamofireNetworkActivityIndicator
				Section(header: Text("AlamofireNetworkActivityIndicator").font(.headline)) {
					Text(AlamofireNetworkActivityIndicatorLicense)
						.font(.system(size: 14, weight: .regular, design: .monospaced))
						.padding(.bottom)
				}
				.onTapGesture {
					guard let url = self.AlamofireNetworkActivityIndicatorURL else { return }
					generateHaptic(.light)
					UIApplication.shared.open(url)
				}
				
				// SwiftyJSON
				Section(header: Text("SwiftyJSON").font(.headline)) {
					Text(SwiftyJSONLicense)
						.font(.system(size: 14, weight: .regular, design: .monospaced))
						.padding(.bottom)
				}
				.onTapGesture {
					guard let url = self.SwiftyJSONURL else { return }
					generateHaptic(.light)
					UIApplication.shared.open(url)
				}
				
				// KeychainAccess
				Section(header: Text("KeychainAccess").font(.headline)) {
					Text(KeychainAccessLicense)
						.font(.system(size: 14, weight: .regular, design: .monospaced))
						.padding(.bottom)
				}
				.onTapGesture {
					guard let url = self.KeychainAccessURL else { return }
					generateHaptic(.light)
					UIApplication.shared.open(url)
				}
				
				// DrawerView
				Section(header: Text("DrawerView").font(.headline)) {
					Text(DrawerViewLicense)
						.font(.system(size: 14, weight: .regular, design: .monospaced))
						.padding(.bottom)
				}
				.onTapGesture {
					guard let url = self.DrawerViewURL else { return }
					generateHaptic(.light)
					UIApplication.shared.open(url)
				}
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
			.padding()
		}
		.navigationBarTitle(Text("Libraries"))
	}
}

struct SettingsView: View {
	@EnvironmentObject var Containers: ContainersModel
	@EnvironmentObject var Settings: SettingsModel
	@State private var showingResetSheet: Bool = false
	@State var showingResetAlert: Bool = false
	@State var showingSetupView: Bool = false
	@State var endpointURL: String = ""
	
	var body: some View {
		List {
			// API
			SettingsSection(header: "API") {
				// Endpoint URL
				VStack(alignment: .leading, spacing: 4) {
					Text("Endpoint URL")
						.font(.body)
						.bold()
						.padding(.bottom, 5)
					TextField("http://172.17.0.2:9000", text: self.$Settings.endpointURL) {
						if (!self.Settings.endpointURL.hasPrefix("https://") && !self.Settings.endpointURL.hasPrefix("http://")) {
							self.Settings.endpointURL = "http://\(self.Settings.endpointURL)"
						}
						if (self.Settings.endpointURL.hasSuffix("/")) {
							self.Settings.endpointURL = String(self.Settings.endpointURL.dropLast())
						}
						
						print("[!] endpointURL set: \"\(self.Settings.endpointURL)\"")
						generateHaptic(.success)
						self.Containers.getContainers()
					}
					.disableAutocorrection(true)
					.keyboardType(.URL)
					.textContentType(.URL)
					.padding(.vertical, 2)
					Text("SETTINGS_ENDPOINTURL_TOOLTIP")
						.font(.footnote)
						.opacity(0.5)
				}
				
				// Automatic refresh
				VStack(alignment: .leading, spacing: 4) {
					Toggle(isOn: self.$Settings.automaticRefresh, label: {
						Text("SETTINGS_AUTOMATICREFRESH")
							.font(.body)
							.bold()
						Spacer()
					})
					Text("SETTINGS_AUTOMATICREFRESH_TOOLTIP : \(String(Int(self.Settings.refreshInterval)))")
						.font(.footnote)
						.opacity(0.5)
				}
				
				// Log in/out
				HStack {
					if (self.Containers.loggedIn) {
						Text("SETTINGS_LOGGEDIN : \(self.Containers.username)")
							.font(.body)
							.bold()
							.id("settings:loggedin:" + self.Containers.username)
						Spacer()
						Button(action: {
							generateHaptic(.light)
							withAnimation {
								// self.Containers.login(username: "", password: "")
								self.Containers.loggedIn = false
								// self.Settings.loggedIn = false
							}
						}) {
							Text("Log out")
								.foregroundColor(.red)
								.id("settings:logout")
						}
						.id("settings:loggedin")
					} else {
						Text("Not logged in")
							.font(.body)
							.bold()
							.id("settings:notloggedin:")
						Spacer()
						Button(action: {
							generateHaptic(.light)
							withAnimation {
								self.showingSetupView = true
							}
						}) {
							Text("Log in")
								.foregroundColor(.blue)
								.id("settings:login")
						}
						.id("settings:notloggedin")
					}
				}
				.transition(.opacity)
				.animation(.easeInOut(duration: 0.25))
			}
			
			// Interface
			SettingsSection(header: "Interface") {
				// Haptic feedback
				VStack(alignment: .leading, spacing: 4) {
					Toggle(isOn: self.$Settings.hapticFeedback, label: {
						Text("SETTINGS_HAPTICFEEDBACK")
							.font(.body)
							.bold()
						Spacer()
					})
					Text("SETTINGS_HAPTICFEEDBACK_TOOLTIP")
						.font(.footnote)
						.opacity(0.5)
				}
				
				// Enable drawer
				VStack(alignment: .leading, spacing: 4) {
					Toggle(isOn: self.$Settings.enableDrawer, label: {
						Text("SETTINGS_ENABLEDRAWER")
							.font(.body)
							.bold()
						Spacer()
					})
					Text("SETTINGS_ENABLEDRAWER_TOOLTIP")
						.font(.footnote)
						.opacity(0.5)
				}
				
				// Use fullscreen dashboard
				if (UIDevice.current.userInterfaceIdiom != .phone) {
					VStack(alignment: .leading, spacing: 4) {
						Toggle(isOn: self.$Settings.useFullScreenDashboard, label: {
							Text("SETTINGS_FULLSCREENDASHBOARD")
								.font(.body)
								.bold()
							Spacer()
						})
						Text("SETTINGS_FULLSCREENDASHBOARD_TOOLTIP")
							.font(.footnote)
							.opacity(0.5)
					}
				}
				
				// Alternate icons
				if (UIApplication.shared.supportsAlternateIcons) {
					NavigationLink(destination: IconSettingsView()) {
						Text("SETTINGS_CHANGEICON")
							.font(.body)
							.bold()
					}
				}
			}
			
			// Other
			SettingsSection(header: "Other", isLast: true) {
				// About
				NavigationLink(destination: AboutView()) {
					Text("About")
				}
				
				// Privacy
				NavigationLink(destination: PrivacyView()) {
					Text("Privacy")
				}
				
				// Libraries
				NavigationLink(destination: LegalView()) {
					Text("Libraries")
				}
				
				// Debug menu
				#if DEBUG
				NavigationLink(destination: DebugView().environmentObject(self.Settings).environmentObject(self.Containers)) {
					Text("🤫")
				}
				#endif
				
				// Updates
				if (self.Settings.updatesAvailable) {
					HStack {
						Spacer()
						Button(action: {
							guard let url = URL(string: "https://github.com/rrroyal/Harbour/releases/latest") else { return }
							generateHaptic(.light)
							UIApplication.shared.open(url)
						}) {
							Text("New update available!")
								.bold()
						}
						Spacer()
					}
				}
				
				// Reset button
				HStack {
					Spacer()
					Button(action: {
						generateHaptic(.warning)
						self.showingResetSheet = true
					}) {
						Text("Reset user settings")
							.foregroundColor(.red)
					}
					Spacer()
				}
			}
		}
		.listStyle(GroupedListStyle())
		.environment(\.horizontalSizeClass, .regular)
		.navigationBarTitle(Text("Settings"))
		.transition(.opacity)
		.animation(.easeInOut)
		.sheet(isPresented: $showingSetupView, content: { SetupView(isPresented: self.$showingSetupView, isParentPresented: self.$showingSetupView, hasParent: false).environmentObject(self.Containers) })
		.alert(isPresented: $showingResetAlert) { () -> Alert in
			Alert(
				title: Text("Done!"),
				message: Text("SETTINGS_RESETTED"),
				primaryButton: .destructive(
					Text("Yes"),
					action: { print("[!] Exiting."); exit(0) }
				),
				secondaryButton: .default(Text("No"))
			)
        }
		.actionSheet(isPresented: $showingResetSheet) {
			ActionSheet(title: Text("SETTINGS_RESET"), message: Text("SETTINGS_RESET_TOOLTIP"), buttons: [
				.destructive(Text("Reset")) {
					generateHaptic(.medium)
					self.Settings.resetSettings()
					self.showingResetAlert = true
				},
				.cancel(Text("Nevermind"))
			])
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
			.environmentObject(SettingsModel())
			.environmentObject(ContainersModel())
    }
}
