//
//  ContainerLogsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import Observation
#if canImport(UIKit)
import UIKit.UIPasteboard
#elseif canImport(AppKit)
import AppKit.NSPasteboard
#endif

// MARK: - ContainerLogsView+ViewModel

extension ContainerLogsView {
	@Observable
	final class ViewModel: @unchecked Sendable {
		typealias _ViewState = ViewState<String, Error>

		private let portainerStore = PortainerStore.shared

		private var fetchTask: Task<Void, Never>?
		private var parseTask: Task<Void, Never>?

		let navigationItem: ContainerDetailsView.NavigationItem

		var includeTimestamps = false
		var lineCount = 100

		private(set) var viewState: _ViewState = .loading

		var logs: String? {
			viewState.value
		}

		var isLoading: Bool {
			viewState.isLoading || !(fetchTask?.isCancelled ?? true) || !(parseTask?.isCancelled ?? true)
		}

		var showBackgroundPlaceholder: Bool {
			logs?.isEmpty ?? true
		}

		init(navigationItem: ContainerDetailsView.NavigationItem) {
			self.navigationItem = navigationItem
		}

		@discardableResult
		func getLogs(errorHandler: ErrorHandler) -> Task<Void, Never> {
			fetchTask?.cancel()
			let task = Task { @MainActor in
				defer { self.fetchTask = nil }

				self.viewState = viewState.reloading
				self.parseTask?.cancel()

				do {
					let logs = try await portainerStore.getLogs(
						for: navigationItem.id,
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
					errorHandler(error)
					self.viewState = .failure(error)
				}
			}
			self.fetchTask = task
			return task
		}
	}
}
