//
//  ContainerLogsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit
#if canImport(UIKit)
import UIKit.UIPasteboard
#elseif canImport(AppKit)
import AppKit.NSPasteboard
#endif

// MARK: - ContainerLogsView+ViewModel

extension ContainerLogsView {
	@Observable @MainActor
	final class ViewModel {
		typealias _ViewState = ViewState<String, Error>

		private let portainerStore = PortainerStore.shared

		private var fetchTask: Task<Void, Error>?
		private var parseTask: Task<Void, Never>?

		private(set) var viewState: _ViewState = .loading

		var containerID: Container.ID

		var scrollViewIsRefreshing = false

		var lineCount = 100

		var searchText: String = ""
		var isSearchVisible = false
		var isSearchFilteringLines = false

		var logs: [String]? {
			viewState.value?
				.split(separator: "\n")
				.filter {
					(isSearchVisible && isSearchFilteringLines && !searchText.isEmpty) ? $0.localizedCaseInsensitiveContains(searchText) : true
				}
				.map { String($0) }
		}

		var searchOccurences: Int? {
			guard isSearchVisible, !searchText.isEmpty else { return nil }
			guard let logs else { return nil }
			let searchTextLowercased = searchText.lowercased()
			return logs.reduce(into: 0) { result, line in
				result += line.lowercased().components(separatedBy: searchTextLowercased).count - 1
			}
		}

		var isLoading: Bool {
			viewState.isLoading || !(fetchTask?.isCancelled ?? true) || !(parseTask?.isCancelled ?? true)
		}

		var isStatusProgressViewVisible: Bool {
			!scrollViewIsRefreshing &&
			(
				(viewState.isLoading && viewState.showAdditionalLoadingView) ||
				(isLoading && !showBackgroundPlaceholder)
			)
		}

		var showBackgroundPlaceholder: Bool {
			logs?.isEmpty ?? true
		}

		init(containerID: Container.ID) {
			self.containerID = containerID
		}

		@discardableResult
		func getLogs() -> Task<Void, Error> {
			fetchTask?.cancel()
			let task = Task { @MainActor in
				defer { self.fetchTask = nil }

				self.viewState = viewState.reloading
				self.parseTask?.cancel()

				do {
					// https://github.com/portainer/portainer/blob/8bb5129be039c3e606fb1dcc5b31e5f5022b5a7e/app/docker/helpers/logHelper/formatLogs.ts#L124
					let logs = try await portainerStore.fetchContainerLogs(
						for: containerID,
						tail: .limit(lineCount),
						timestamps: Preferences.shared.clIncludeTimestamps
					)
//					.dropFirst(8)												// first line
//					.replacing(/\r?\n(.{8})/.dotMatchesNewlines(), with: "\n")	// the rest of the lines
					.split(separator: "\n")
					.map { $0.dropFirst(8) }
					.joined(separator: "\n")

					Task.detached {
						let logsParsed = ANSIParser.trim(String(logs))
						guard !Task.isCancelled else { return }
						await MainActor.run {
							self.viewState = .success(logsParsed)
						}
					}
				} catch {
					guard !error.isCancellationError else { return }
					self.viewState = .failure(error)
					throw error
				}
			}
			self.fetchTask = task
			return task
		}
	}
}
