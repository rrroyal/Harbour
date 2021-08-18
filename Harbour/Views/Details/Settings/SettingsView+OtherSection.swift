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
			VStack(spacing: 3) {
				Text("Harbour v\(Bundle.main.buildVersion) (#\(Bundle.main.buildNumber))")
					.font(.subheadline.weight(.semibold))
					.foregroundColor(.secondary)
					.opacity(Globals.Views.secondaryOpacity)
				
				Link(destination: URL(string: "https://github.com/rrunitears/Harbour")!) {
					Text("Made with ❤️ (and ☕️) by @unitears")
						.font(.subheadline.weight(.semibold))
						.foregroundColor(.secondary)
						.opacity(Globals.Views.secondaryOpacity)
				}
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.vertical)
		}
		
		var body: some View {
			Section(header: Text("Other"), footer: madeWithLove) {
				NavigationLink("🤫") {
					DebugView()
				}
			}
		}
	}
}
