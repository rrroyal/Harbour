//
//  SettingsView+OtherSection.swift
//  Harbour
//
//  Created by royal on 18/08/2021.
//

import SwiftUI

extension SettingsView {
	struct OtherSection: View {
		var madeWithLove: some View {
			Link(destination: URL(string: "https://github.com/rrroyal/Harbour")!) {
				VStack(spacing: 5) {
					Text(Localization.SETTINGS_FOOTER.localized)
					Text("Harbour v\(Bundle.main.buildVersion) (#\(Bundle.main.buildNumber))")
				}
				.font(.subheadline.weight(.semibold))
				.opacity(Constants.secondaryOpacity)
			}
			.tint(.secondary)
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.top)
		}
		
		var body: some View {
			Section(header: Text("Other"), footer: madeWithLove) {
				#if DEBUG
				NavigationLinkOption(label: "🤫", iconSymbolName: "eyes", iconColor: .orange) {
					DebugView()
				}
				#endif
				
				Link(destination: URL(string: "https://harbour.shameful.xyz/docs")!) {
					HStack {
						OptionIcon(symbolName: "doc.append", color: .blue)
						
						Text("Docs")
							.font(standaloneLabelFont)
						
						Spacer()
						
						Image(systemName: "link")
							.font(.subheadline.weight(.semibold))
							.foregroundStyle(.tertiary)
					}
				}
				.foregroundStyle(.primary)
			}
		}
	}
}
