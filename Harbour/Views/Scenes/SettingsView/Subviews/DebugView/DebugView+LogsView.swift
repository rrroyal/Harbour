//
//  DebugView+LogsView.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
import OSLog
import SwiftUI

// MARK: - DebugView+LogsView

extension DebugView {
	struct LogsView: View {
		@State private var logs: [LogEntry] = []
		@State private var filter: String = ""

		private var filteredLogs: [LogEntry] {
			guard !filter.isEmpty else { return logs }
			return logs.filter {
				$0.message.localizedCaseInsensitiveContains(filter) ||
				($0.category?.localizedCaseInsensitiveContains(filter) ?? false)
			}
		}

		@ViewBuilder
		private var toolbarMenu: some View {
			Menu {
				Button {
					Haptics.generateIfEnabled(.buttonPress)
					getLogs()
				} label: {
					Label("Generic.Refresh", systemImage: SFSymbol.reload)
				}

				Divider()

				Group {
					let logsShareable = logs.map(\.message).joined(separator: "\n")
					CopyButton(content: logsShareable)
					ShareLink(item: logsShareable, preview: .init(.init(verbatim: logsShareable)))
				}
			} label: {
				Label("Generic.More", systemImage: SFSymbol.moreCircle)
			}
		}

		var body: some View {
			List(filteredLogs, id: \.self) { entry in
				Section(content: {
					Text(entry.message)
						.font(.system(.subheadline, design: .monospaced))
						.multilineTextAlignment(.leading)
						.lineLimit(nil)
						.textSelection(.enabled)
				}, header: {
					Text(verbatim: "\(entry.category ?? "<none>") - \(entry.date?.ISO8601Format() ?? "<none>") [\(entry.levelReadable)]")
						.font(.system(.footnote, design: .monospaced))
						.textCase(.none)
				})
				.listRowBackground(entry.color?.opacity(0.1))
			}
			.navigationTitle("DebugView.LogsView.Title")
			.navigationBarTitleDisplayMode(.inline)
			.listStyle(.grouped)
			.searchable(text: $filter)
			.scrollDismissesKeyboard(.interactively)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					toolbarMenu
				}
			}
			.onAppear {
				getLogs()
			}
		}

		func getLogs() {
			Task {
				do {
					let logStore = try OSLogStore(scope: .currentProcessIdentifier)
					let position = logStore.position(date: Date().addingTimeInterval(-(6 * 60 * 60)))
					// swiftlint:disable:next force_unwrapping
					let predicate = NSPredicate(format: "subsystem CONTAINS[c] %@", Bundle.main.mainBundleIdentifier!)
					let entries = try logStore.getEntries(with: [],
														  at: position,
														  matching: predicate)
					logs = entries
						.compactMap { $0 as? OSLogEntryLog }
						.map { LogEntry(message: $0.composedMessage, level: $0.level, date: $0.date, category: $0.category) }
				} catch {
					logs = [LogEntry(message: error.localizedDescription, level: nil, date: nil, category: nil)]
				}
			}
		}
	}
}

// MARK: - DebugView.LogsView+LogEntry

private extension DebugView.LogsView {
	struct LogEntry: Hashable, CustomDebugStringConvertible {
		let message: String
		let level: OSLogEntryLog.Level?
		let date: Date?
		let category: String?

		var debugDescription: String {
			"(\(level?.rawValue ?? -1)) \(date?.ISO8601Format() ?? String(localized: "Generic.None")) [\(category ?? String(localized: "Generic.None"))] \(message)"
		}

		var color: Color? {
			switch level {
			case .debug:			.purple
			case .info:				.blue
			case .notice:			nil
			case .error:			.yellow
			case .fault:			.red
			case nil, .undefined:	nil
			@unknown default:		nil
			}
		}

		var levelReadable: String {
			switch level {
			case .debug:			String(localized: "DebugView.LogsView.LogLevel.Debug")
			case .info:				String(localized: "DebugView.LogsView.LogLevel.Info")
			case .notice:			String(localized: "DebugView.LogsView.LogLevel.Notice")
			case .error:			String(localized: "DebugView.LogsView.LogLevel.Error")
			case .fault:			String(localized: "DebugView.LogsView.LogLevel.Fault")
			case nil, .undefined:	String(localized: "DebugView.LogsView.LogLevel.None")
			@unknown default:		String(localized: "DebugView.LogsView.LogLevel.Unknown")
			}
		}
	}
}

// MARK: - Previews

/*
#Preview {
	DebugView.LogsView()
}
*/
