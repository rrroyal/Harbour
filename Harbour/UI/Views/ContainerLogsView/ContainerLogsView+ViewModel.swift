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
	@Observable
	final class ViewModel {
		typealias _ViewState = ViewState<String, Error>

		private let portainerStore = PortainerStore.shared

		private var fetchTask: Task<Void, Error>?
		private var parseTask: Task<Void, Never>?

		private(set) var viewState: _ViewState = .loading

		var containerID: Container.ID

		var scrollViewIsRefreshing = false

		var includeTimestamps = false
		var lineCount = 100

		var logs: String? {
			viewState.value
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
					let logs = try await portainerStore.fetchContainerLogs(
						for: containerID,
						tail: .limit(lineCount),
						timestamps: includeTimestamps
					)

					Task.detached {
						let logsParsed = ANSIParser.trim(logs)
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
