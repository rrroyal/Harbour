//
//  DebugView+LogsView.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import SwiftUI
import OSLog
import CommonFoundation
import CommonHaptics

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
			Menu(content: {
				Button(action: {
					Haptics.generateIfEnabled(.selectionChanged)
					UIPasteboard.general.string = logs.map(\.debugDescription).joined(separator: "\n")
				}) {
					Label("Copy", systemImage: SFSymbol.copy)
				}

				Divider()

				Button(action: {
					Haptics.generateIfEnabled(.buttonPress)
					getLogs()
				}) {
					Label("Refresh", systemImage: SFSymbol.reload)
				}
			}) {
				Image(systemName: SFSymbol.more)
					.symbolVariant(.circle)
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
					Text("\(entry.category ?? "<none>") - \(entry.date?.ISO8601Format() ?? "<none>") [\(entry.level?.rawValue ?? -1)]")
						.font(.system(.footnote, design: .monospaced))
						.textCase(.none)
				})
				.listRowBackground(entry.color?.opacity(0.1))
			}
			.navigationTitle("Logs")
			.navigationBarTitleDisplayMode(.inline)
			.listStyle(.grouped)
			.searchable(text: $filter)
			.scrollDismissesKeyboard(.interactively)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
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
					let predicate = NSPredicate(format: "subsystem CONTAINS[c] %@", Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!)
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
			"(\(level?.rawValue ?? -1)) \(date?.ISO8601Format() ?? "<none>") [\(category ?? "<none>")] \(message)"
		}

		var color: Color? {
			guard let level = level else { return nil }
			switch level {
				case .undefined:
					return nil
				case .debug:
					return .purple
				case .info:
					return nil
				case .notice:
					return .blue
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

// MARK: - Previews

struct DebugView_LogsView_Previews: PreviewProvider {
	static var previews: some View {
		DebugView.LogsView()
	}
}
