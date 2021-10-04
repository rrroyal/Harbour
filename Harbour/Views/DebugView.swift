//
//  DebugView.swift
//  Harbour
//
//  Created by unitears on 19/06/2021.
//

#if DEBUG

import SwiftUI
import OSLog

struct DebugView: View {
    var body: some View {
		List {
			Section("Build info") {
				Labeled(label: "Bundle ID", content: Bundle.main.bundleIdentifier, monospace: true)
				Labeled(label: "App prefix", content: Bundle.main.appIdentifierPrefix, monospace: true)
			}
			
			Section("UserDefaults") {
				Button("Reset finishedSetup") {
					Preferences.shared.finishedSetup = false
				}
				
				Button("Reset all") {
					Preferences.Key.allCases.forEach { Preferences.shared.ud.removeObject(forKey: $0.rawValue) }
					exit(0)
				}
				.accentColor(.red)
			}
			
			Section {
				NavigationLink(destination: LogsView()) {
					Text("Logs")
				}
 			}
		}
		.navigationTitle("🤫")
    }
}

extension DebugView {
	struct LogsView: View {
		@State private var logs: [String] = []
		
		var body: some View {
			List(logs, id: \.self) { entry in
				Text(entry)
					.lineLimit(nil)
					.frame(maxWidth: .infinity, alignment: .topLeading)
					.contentShape(Rectangle())
					.textSelection(.enabled)
			}
			.font(.system(.footnote, design: .monospaced))
			.listStyle(.plain)
			.navigationTitle("Logs")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						UIDevice.current.generateHaptic(.light)
						getLogs()
					}) {
						Image(systemName: "arrow.clockwise")
					}
				}
			}
			.onAppear(perform: getLogs)
		}
		
		func getLogs() {
			do {
				let logStore = try OSLogStore(scope: .currentProcessIdentifier)
				let entries = try logStore.getEntries()
				logs = entries
					.compactMap { $0 as? OSLogEntryLog }
					.filter { $0.subsystem.contains(Bundle.main.bundleIdentifier!) }
					.map { "[\($0.level.rawValue)] \($0.date): \($0.category): \($0.composedMessage)" }
			} catch {
				logs = [String(describing: error)]
			}
		}
	}
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}

#endif
