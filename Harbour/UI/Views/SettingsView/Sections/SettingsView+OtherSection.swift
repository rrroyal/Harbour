//
//  SettingsView+OtherSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

// MARK: - SettingsView+OtherSection

extension SettingsView {
	struct OtherSection: View {
		@Environment(SettingsView.ViewModel.self) var viewModel

		var body: some View {
			NormalizedSection {
				NavigationLinkOption("SettingsView.Other.Debug", iconSymbolName: "wrench.and.screwdriver") {
					DebugView()
				}
				.id(SettingsView.ViewID.otherDebugNavigation)
			} header: {
				Text("SettingsView.Other.Title")
			} footer: {
				FooterView()
			}
		}
	}
}

// MARK: - SettingsView.OtherSection+Components

private extension SettingsView.OtherSection {
	struct FooterView: View {
		@Environment(SettingsView.ViewModel.self) var viewModel

		// swiftlint:disable:next force_unwrapping
		private let githubURL = URL(string: "https://github.com/rrroyal/Harbour")!

		var body: some View {
			VStack(alignment: .center, spacing: 5) {
				Link(
					"SettingsView.Other.Footer.Headline",
					destination: githubURL
				)

				Text("SettingsView.Other.Footer.Subheadline BuildVersion:\(Bundle.main.buildVersion) BuildNumber:\(Bundle.main.buildNumber)")

				if viewModel.isNegraButtonVisible {
					Button("SettingsView.Other.Footer.NegraButton") {
						Haptics.generateIfEnabled(.sheetPresentation)
						viewModel.isNegraSheetPresented = true
					}
					.buttonStyle(.plain)
				}
			}
			.font(.callout)
			.fontWeight(.semibold)
			.foregroundStyle(.primary)
			.opacity(Constants.secondaryOpacity)
			.frame(maxWidth: .infinity)
			.padding(.vertical)
		}
	}
}
