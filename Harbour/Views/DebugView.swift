//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 19/06/2021.
//

import SwiftUI
import OSLog
import Indicators

struct DebugView: View {
    var body: some View {
		List {
			Section(header: Text("Build info")) {
				Labeled(label: "Bundle ID", content: Bundle.main.bundleIdentifier, monospace: true)
				Labeled(label: "App prefix", content: Bundle.main.appIdentifierPrefix, monospace: true)
			}
			
			Section(header: Text("UserDefaults")) {
				Button("Reset finishedSetup") {
					UIDevice.current.generateHaptic(.light)
					Preferences.shared.finishedSetup = false
				}
				
				Button("Reset all") {
					UIDevice.current.generateHaptic(.heavy)
					Preferences.Key.allCases.forEach { Preferences.shared.ud.removeObject(forKey: $0.rawValue) }
					exit(0)
				}
				.accentColor(.red)
			}
			
			Section(header: Text("Indicators")) {
				Button("Display manual indicator") {
					let indicator: Indicators.Indicator = .init(id: "manual", icon: "bolt", headline: "Headline", subheadline: "Subheadline", expandedText: "Expanded text that is really long and should be truncated normally", dismissType: .manual)
					UIDevice.current.generateHaptic(.light)
					AppState.shared.indicators.display(indicator)
				}
				
				Button("Display automatic indicator") {
					let indicator: Indicators.Indicator = .init(id: "automatic", icon: "bolt", headline: "Headline", subheadline: "Subheadline", expandedText: "Expanded text that is really long and should be truncated normally", dismissType: .after(5))
					UIDevice.current.generateHaptic(.light)
					AppState.shared.indicators.display(indicator)
				}
			}
			
			Section {
				Button("Copy logs") {
					UIDevice.current.generateHaptic(.light)
					UIPasteboard.general.string = _LOGS.joined(separator: "\n")
				}
			}
		}
		.navigationTitle("🤫")
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
