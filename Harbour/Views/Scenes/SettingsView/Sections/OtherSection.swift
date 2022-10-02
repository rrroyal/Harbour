//
//  OtherSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// MARK: - SettingsView+OtherSection

extension SettingsView {
	struct OtherSection: View {
		var body: some View {
			Section(header: Text(Localizable.Settings.Other.title), footer: FooterView()) {
				NavigationLinkOption(label: Localizable.Settings.Other.debug, iconSymbolName: "wrench.and.screwdriver") {
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
		let githubURL: URL = URL(string: "https://github.com/rrroyal/Harbour")!

		var body: some View {
			Link(destination: githubURL) {
				VStack(alignment: .center, spacing: 5) {
					Text(Localizable.Settings.Other.footer)
					Text("\(Localizable.appName) v\(Bundle.main.buildVersion) (#\(Bundle.main.buildNumber))")
				}
			}
			.font(.subheadline.weight(.semibold))
			.foregroundStyle(.primary)
			.opacity(.secondary)
			.frame(maxWidth: .infinity)
			.padding(.vertical)
		}
	}
}

// MARK: - Previews

struct OtherSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.OtherSection()
	}
}
