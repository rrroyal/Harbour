//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 19/06/2021.
//

#if DEBUG

import SwiftUI
import OSLog
import Indicators
import BackgroundTasks

struct DebugView: View {
	@EnvironmentObject var sceneState: SceneState
	@State private var pendingBackgroundTasks: [BGTaskRequest] = []
	
    var body: some View {
		List {
			Section("Portainer") {
				Button("Reset servers") {
					UIDevice.generateHaptic(.light)
					Preferences.shared.selectedServer = nil
					Preferences.shared.selectedEndpointID = nil
					Portainer.shared.cleanup()
				}
			}
			
			Section("Background Tasks") {
				Labeled(label: "Last task", content: Preferences.shared.lastBackgroundTaskDate?.formatted(), hideIfEmpty: false)
				
				DisclosureGroup("Scheduled tasks") {
					ForEach(pendingBackgroundTasks, id: \.identifier) { task in
						Text(task.identifier)
					}
				}
			}
			.onAppear {
				Task { pendingBackgroundTasks = await BGTaskScheduler.shared.pendingTaskRequests() }
			}
			
			Section("UserDefaults") {
				Button("Reset finishedSetup") {
					UIDevice.generateHaptic(.light)
					Preferences.shared.finishedSetup = false
				}
				
				Button("Reset all") {
					UIDevice.generateHaptic(.heavy)
					Preferences.Key.allCases.forEach { Preferences.ud.removeObject(forKey: $0.rawValue) }
					exit(0)
				}
				.foregroundStyle(.red)
			}
			
			Section("Indicators") {
				Button("Display manual indicator") {
					let indicator: Indicators.Indicator = .init(id: "manual", icon: "bolt", headline: "Headline", subheadline: "Subheadline", expandedText: "Expanded text that is really long and should be truncated normally", dismissType: .manual)
					UIDevice.generateHaptic(.light)
					sceneState.indicators.display(indicator)
				}
				
				Button("Display automatic indicator") {
					let indicator: Indicators.Indicator = .init(id: "automatic", icon: "bolt", headline: "Headline", subheadline: "Subheadline", expandedText: "Expanded text that is really long and should be truncated normally", dismissType: .after(5))
					UIDevice.generateHaptic(.light)
					sceneState.indicators.display(indicator)
				}
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
						UIDevice.generateHaptic(.light)
						getLogs()
					}) {
						Image(systemName: "arrow.clockwise")
					}
				}
			}
			.onAppear(perform: getLogs)
		}
		
		func getLogs() {
			DispatchQueue.main.async {
				do {
					let logStore = try OSLogStore(scope: .currentProcessIdentifier)
					let entries = try logStore.getEntries()
					logs = entries
						.compactMap { $0 as? OSLogEntryLog }
						.filter { $0.subsystem.contains(Bundle.main.bundleIdentifier!) }
						.map { "[\($0.level.rawValue)] \($0.date) [\($0.category)] \($0.composedMessage)" }
				} catch {
					logs = [String(describing: error)]
				}
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
