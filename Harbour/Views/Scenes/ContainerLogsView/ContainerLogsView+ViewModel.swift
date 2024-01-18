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

		@ObservationIgnored
		private var fetchTask: Task<Void, Never>?
		@ObservationIgnored
		private var parseTask: Task<Void, Never>?

		private(set) var viewState: _ViewState = .loading
		private(set) var logsParsed: AttributedString?

		let navigationItem: ContainerDetailsView.NavigationItem

		var includeTimestamps = false
		var lineCount = 100

		var logsViewable: AttributedString? {
			if let logsParsed { return logsParsed }
			if let logs = viewState.value { return AttributedString(stringLiteral: ANSIParser.trim(logs)) }
			return nil
		}

		init(navigationItem: ContainerDetailsView.NavigationItem) {
			self.navigationItem = navigationItem
		}

		@discardableResult
		func getLogs(errorHandler: ErrorHandler) -> Task<Void, Never> {
			fetchTask?.cancel()
			let task = Task { @MainActor in
				self.viewState = viewState.reloading
				self.parseTask?.cancel()

				do {
					let logs = try await portainerStore.getLogs(
						for: navigationItem.id,
						tail: lineCount,
						timestamps: includeTimestamps
					)
					self.viewState = .success(logs)

					self.parseTask = Task.detached {
						let logsParsed = ANSIParser.parse(logs)
						await MainActor.run {
							guard !Task.isCancelled else { return }
							self.logsParsed = logsParsed
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
