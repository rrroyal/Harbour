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
import PortainerKit
import SwiftUI

// MARK: - DebugView+LogsView

extension DebugView {
	struct LogsView: View {
		@State private var isLoading = false
		@State private var logsTask: Task<Void, Never>?
		@State private var logs: [LogEntry] = []
		@State private var filter: String = ""
		@State private var includePortainerKitLogs = false
		@State private var scrollViewIsRefreshing = false

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

				Toggle("DebugView.LogsView.IncludePortainerKitLogs", isOn: $includePortainerKitLogs.withHaptics(.selectionChanged))
					.onChange(of: includePortainerKitLogs) {
						getLogs()
					}

				Divider()

				Group {
					let logsShareable = logs.map(\.message).joined(separator: "\n")
					CopyButton(content: logsShareable)
					ShareLink(item: logsShareable, preview: .init(.init(verbatim: logsShareable)))
				}
			} label: {
				Label("Generic.More", systemImage: SFSymbol._moreToolbar)
					.labelStyle(.iconOnly)
			}
			.labelStyle(.titleAndIcon)
		}

		var body: some View {
			Form {
				ForEach(filteredLogs, id: \.self) { entry in
					Section {
						Text(entry.message)
							.font(.footnote)
							.fontDesign(.monospaced)
							.multilineTextAlignment(.leading)
							.lineLimit(nil)
							.textSelection(.enabled)
					} header: {
						Text(verbatim: "\(entry.category ?? "<none>") - \(entry.date?.ISO8601Format() ?? "<none>") [\(entry.levelReadable)]")
							.font(.caption2)
							.fontDesign(.monospaced)
							.textCase(.none)
							.textSelection(.enabled)
							.lineLimit(2)
					}
					.listRowBackground(entry.color?.opacity(0.1))
				}
			}
			.formStyle(.grouped)
			.searchable(text: $filter)
			.defaultScrollAnchor(.bottom, for: .initialOffset)
			.navigationTitle("DebugView.LogsView.Title")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					toolbarMenu
				}

				ToolbarItem(placement: .status) {
					if isLoading && !scrollViewIsRefreshing {
						ProgressView()
					}
				}
			}
//			.toolbarVisibility(isLoading && !scrollViewIsRefreshing ? .visible : .hidden, for: .status)
			.refreshable(binding: $scrollViewIsRefreshing) {
				await getLogs(showIndicator: false).value
			}
			.task {
				await getLogs().value
			}
			.animation(.default, value: isLoading)
			.animation(.default, value: logs)
		}

		@discardableResult
		func getLogs(showIndicator: Bool = true) -> Task<Void, Never> {
			self.logsTask?.cancel()
			let task = Task.detached {
				if showIndicator {
					await MainActor.run {
						isLoading = true
					}
				}
				defer {
					Task { @MainActor in
						isLoading = false
					}
				}

			fetchLogs:
				do {
					let logStore = try OSLogStore(scope: .currentProcessIdentifier)
					let position = logStore.position(date: Date().addingTimeInterval(-(6 * 60 * 60)))

					var predicates: [NSPredicate] = [
						// swiftlint:disable:next force_unwrapping
						NSPredicate(format: "subsystem CONTAINS[c] %@", Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!)
					]
					if await includePortainerKitLogs {
						predicates.append(NSPredicate(format: "subsystem CONTAINS[c] %@", PortainerClient.bundleIdentifier))
					}

					let entries = try logStore.getEntries(
						with: [],
						at: position,
						matching: NSCompoundPredicate(
							type: .or,
							subpredicates: predicates
						)
					)

					guard !Task.isCancelled else { break fetchLogs }

					let logs = entries
						.compactMap { $0 as? OSLogEntryLog }
						.map { LogEntry(message: $0.composedMessage, level: $0.level, date: $0.date, category: $0.category) }
					await MainActor.run {
						self.logs = logs
					}
				} catch {
					let logs = [LogEntry(message: error.localizedDescription, level: nil, date: nil, category: nil)]
					await MainActor.run {
						self.logs = logs
					}
				}
			}
			self.logsTask = task
			return task
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
			case .info:				nil
			case .notice:			.blue
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
