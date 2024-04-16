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
		@Bindable var viewModel: SettingsView.ViewModel

		var body: some View {
			Section(header: Text("SettingsView.Other.Title"), footer: FooterView(viewModel: viewModel)) {
				NavigationLinkOption("SettingsView.Other.Debug", iconSymbolName: "wrench.and.screwdriver") {
					DebugView()
				}
				.id(SettingsView.ViewID.otherDebugNavigation)
			}
		}
	}
}

// MARK: - SettingsView.OtherSection+Components

private extension SettingsView.OtherSection {
	struct FooterView: View {
		@Bindable var viewModel: SettingsView.ViewModel

		// swiftlint:disable:next force_unwrapping
		private let githubURL = URL(string: "https://github.com/rrroyal/Harbour")!

		var body: some View {
			VStack(alignment: .center, spacing: 5) {
				Link(
					"SettingsView.Other.Footer.Headline",
					destination: githubURL
				)

				Text("SettingsView.Other.Footer.Subheadline BuildVersion:\(Bundle.main.buildVersion) BuildNumber:\(Bundle.main.buildNumber)")

				if viewModel.shouldDisplayNegraButton {
					Button("SettingsView.Other.Footer.NegraButton") {
						Haptics.generateIfEnabled(.sheetPresentation)
						viewModel.isNegraSheetPresented = true
					}
					.buttonStyle(.plain)
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
