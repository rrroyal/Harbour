//
//  ContainerLogsView+SeparatedView.swift
//  Harbour
//
//  Created by royal on 17/11/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - ContainerLogsView+SeparatedView

extension ContainerLogsView {
	struct SeparatedView: View {
		private var logs: [LogEntry]
		private var scrollProxy: ScrollViewProxy
		private var includeTimestamps: Bool

		init(logs: String?, scrollProxy: ScrollViewProxy, includeTimestamps: Bool) {
			self.scrollProxy = scrollProxy
			self.includeTimestamps = includeTimestamps

			if let logs, !logs.isEmpty {
				self.logs = logs
					.split(separator: "\n")
					.enumerated()
					.map { LogEntry(line: $0, string: String($1), includeTimestamps: includeTimestamps) }
			} else {
				self.logs = []
			}
		}

		var body: some View {
			LazyVStack {
				SeparatedLayout {
					ForEach(logs) { logEntry in
						VStack(alignment: .leading, spacing: 2) {
							Text(logEntry.content)
								.font(ContainerLogsView.normalFont)
								.textSelection(.enabled)

							if let date = logEntry.date {
								Text(date, format: .dateTime)
									.font(.caption2)
									.fontDesign(.monospaced)
									.foregroundStyle(.secondary)
							}
						}
						.padding(.vertical, 1)
						.padding(.horizontal, 10)
						.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			.id(ContainerLogsView.ViewID.logsLabel)
		}
	}
}

// MARK: - ContainerLogsView.SeparatedView+LogEntry

private extension ContainerLogsView.SeparatedView {
	struct LogEntry: Hashable, Identifiable {
		private nonisolated(unsafe) static let formatter: ISO8601DateFormatter = {
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
			return formatter
		}()

		var line: Int
		var content: String
		var date: Date?

		var id: Int {
			line
		}

		init(line: Int, string: String, includeTimestamps: Bool) {
			self.line = line

			if includeTimestamps {
				let split = string
					.trimmingCharacters(in: .whitespacesAndNewlines)
					.split(separator: " ", maxSplits: 1)
				let timestamp = String(split[0]).trimmingCharacters(in: .whitespacesAndNewlines)

				self.date = Self.formatter.date(from: timestamp)

				if split.count == 2 {
					self.content = String(split[1])
				} else if self.date != nil {
					self.content = ""
				} else {
					self.content = string
				}
			} else {
				self.content = string
			}
		}
	}
}

// MARK: - ContainerLogsView.SeparatedView+SeparatedLayout

private extension ContainerLogsView.SeparatedView {
	struct SeparatedLayout<Content: View>: View {
		@ViewBuilder var content: Content

		var body: some View {
			Group(subviews: content) { subviews in
				ForEach(Array(subviews.enumerated()), id: \.offset) { index, subview in
					subview

					if subviews.endIndex > index + 1 {
						Divider()
					}
				}
			}
		}
	}
}

// MARK: - Previews

#Preview("Without Timestamps") {
	ScrollViewReader { proxy in
		ScrollView {
			ContainerLogsView.SeparatedView(
				logs: ContainerLogsView.PreviewContext.logs,
				scrollProxy: proxy,
				includeTimestamps: false
			)
		}
	}
}

#Preview("With Timestamps") {
	ScrollViewReader { proxy in
		ScrollView {
			ContainerLogsView.SeparatedView(
				logs: ContainerLogsView.PreviewContext.logsTimestamped,
				scrollProxy: proxy,
				includeTimestamps: true
			)
		}
	}
}
