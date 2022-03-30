//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 19/06/2021.
//

#if TESTFLIGHT

import SwiftUI
import OSLog
import Indicators
import BackgroundTasks
import WidgetKit

struct DebugView: View {
	@EnvironmentObject var sceneState: SceneState
	@State private var pendingBackgroundTasks: [BGTaskRequest] = []
	
    var body: some View {
		List {
			#if DEBUG
			Section("Build") {
				Labeled(label: "Bundle ID", content: Bundle.main.mainBundleIdentifier, monospace: true, hideIfEmpty: false)
				Labeled(label: "AppIdentifierPrefix", content: Bundle.main.appIdentifierPrefix, monospace: true, hideIfEmpty: false)
			}
			#endif
			
			Section("Portainer") {
				Button("Reset servers") {
					UIDevice.generateHaptic(.heavy)
					Preferences.shared.selectedServer = nil
					Preferences.shared.selectedEndpointID = nil
					Portainer.shared.cleanup()
				}
			}

			#if DEBUG
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
			#endif
			
			Section("Widgets") {
				Button("Reload all timelines") {
					UIDevice.generateHaptic(.light)
					WidgetCenter.shared.reloadAllTimelines()
				}
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

			Section("CoreData") {
				Button("Reset all") {
					UIDevice.generateHaptic(.heavy)
					Persistence.shared.reset()
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
		@State private var logs: [LogEntry] = []
		
		var body: some View {
			List(logs, id: \.self) { entry in
				Section(content: {
					Text(entry.message)
						.font(.system(.subheadline, design: .monospaced))
						.multilineTextAlignment(.leading)
						.lineLimit(nil)
						.textSelection(.enabled)
				}, header: {
					Text("\(entry.category ?? "<none>") - \(entry.date?.ISO8601Format() ?? "<none>") [\(entry.level?.rawValue ?? -1)]")
						.font(.system(.footnote, design: .monospaced))
						.textCase(.none)
				})
				.listRowBackground(entry.color?.opacity(0.1))
			}
			.navigationTitle("Logs")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu(content: {
						Button(action: {
							UIDevice.generateHaptic(.selectionChanged)
							UIPasteboard.general.string = logs.map(\.debugDescription).joined(separator: "\n")
						}) {
							Label("Copy", systemImage: "doc.on.doc")
						}
						
						Divider()
						
						Button(action: {
							UIDevice.generateHaptic(.light)
							getLogs()
						}) {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}, label: {
						Image(systemName: "ellipsis")
							.symbolVariant(.circle)
					})
				}
			}
			.onAppear(perform: getLogs)
		}
		
		func getLogs() {
			DispatchQueue.main.async {
				do {
					let logStore = try OSLogStore(scope: .currentProcessIdentifier)
					let position = logStore.position(date: Date().addingTimeInterval(-(6 * 60 * 60)))
					let entries = try logStore.getEntries(with: [], at: position, matching: NSPredicate(format: "subsystem CONTAINS[c] %@", Bundle.main.mainBundleIdentifier))
					logs = entries
						.compactMap { $0 as? OSLogEntryLog }
						.map { LogEntry(message: $0.composedMessage, level: $0.level, date: $0.date, category: $0.category) }
				} catch {
					logs = [LogEntry(message: error.readableDescription, level: nil, date: nil, category: nil)]
				}
			}
		}
		
		struct LogEntry: Hashable, CustomDebugStringConvertible {
			let message: String
			let level: OSLogEntryLog.Level?
			let date: Date?
			let category: String?
			
			var debugDescription: String {
				"(\(level?.rawValue ?? -1)) \(date?.ISO8601Format() ?? "<none>") [\(category ?? "<none>")] \(message)"
			}

			var color: Color? {
				guard let level = level else { return nil }
				switch level {
					case .undefined:
						return nil
					case .debug:
						return .blue
					case .info:
						return nil
					case .notice:
						return .yellow
					case .error:
						return .red
					case .fault:
						return .red
					@unknown default:
						return nil
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
