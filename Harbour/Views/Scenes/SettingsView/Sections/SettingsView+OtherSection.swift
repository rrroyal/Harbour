//
//  SettingsView+OtherSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// MARK: - SettingsView+OtherSection

extension SettingsView {
	struct OtherSection: View {
		var body: some View {
			Section(header: Text("SettingsView.Other.Title"), footer: FooterView()) {
				NavigationLinkOption(label: "SettingsView.Other.Debug", iconSymbolName: "wrench.and.screwdriver") {
					DebugView()
				}
			}
		}
	}
}

// MARK: - SettingsView.OtherSection+Components

private extension SettingsView.OtherSection {
	struct FooterView: View {
		// swiftlint:disable:next force_unwrapping
		let githubURL = URL(string: "https://github.com/rrroyal/Harbour")!

		var body: some View {
			Link(destination: githubURL) {
				VStack(alignment: .center, spacing: 5) {
					Text("SettingsView.Other.Footer.Headline")
					Text("SettingsView.Other.Footer.Subheadline BuildVersion:\(Bundle.main.buildVersion) BuildNumber:\(Bundle.main.buildNumber)")
				}
			}
			.font(.subheadline.weight(.semibold))
			.foregroundStyle(.primary)
			.opacity(Constants.secondaryOpacity)
			.frame(maxWidth: .infinity)
			.padding(.vertical)
		}
	}
}

// MARK: - Previews

/*
#Preview {
	SettingsView.OtherSection()
}
*/
