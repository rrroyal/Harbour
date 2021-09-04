//
//  SettingsView+OtherSection.swift
//  Harbour
//
//  Created by unitears on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	struct OtherSection: View {
		var madeWithLove: some View {
			Link(destination: URL(string: "https://github.com/rrroyal/Harbour")!) {
				VStack(spacing: 5) {
					Text("Made with ❤️ (and ☕️) by @rrroyal")
					Text("Harbour v\(Bundle.main.buildVersion) (#\(Bundle.main.buildNumber))")
				}
				.font(.subheadline.weight(.semibold))
				.foregroundColor(.secondary)
				.opacity(Globals.Views.secondaryOpacity)
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.top)
		}
		
		var body: some View {
			Section(header: Text("Other"), footer: madeWithLove) {
				NavigationLink("Libraries") {
					LibrariesView()
				}
				
				#if DEBUG
				NavigationLink("🤫") {
					DebugView()
				}
				#endif
			}
		}
	}
}

extension SettingsView.OtherSection {
	struct LibrariesView: View {
		typealias Library = (url: URL, label: String)
		
		let libraries: [Library] = [
			(URL(string: "https://github.com/kishikawakatsumi/KeychainAccess")!, "kishikawakatsumi/KeychainAccess")
		]
		
		var body: some View {
			List(libraries, id: \.url) { library in
				Link(destination: library.url) {
					Text(library.label)
				}
			}
			.navigationTitle("Libraries")
		}
	}
}
