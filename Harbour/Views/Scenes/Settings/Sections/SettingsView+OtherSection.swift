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
		private typealias Localization = Localizable.SettingsView.Other

		var body: some View {
			Section(header: Text(Localization.title), footer: FooterView()) {
				NavigationLinkOption(label: Localization.debug, iconSymbolName: "wrench.and.screwdriver") {
					DebugView()
				}
			}
		}
	}
}

// MARK: - SettingsView.OtherSection+Components

private extension SettingsView.OtherSection {
	struct FooterView: View {
		private typealias Localization = Localizable.SettingsView.Other

		// swiftlint:disable:next force_unwrapping
		let githubURL = URL(string: "https://github.com/rrroyal/Harbour")!

		var body: some View {
			Link(destination: githubURL) {
				VStack(alignment: .center, spacing: 5) {
					Text(Localization.footer)
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

#Preview {
	SettingsView.OtherSection()
}
