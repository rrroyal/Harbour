//
//  ContainerLogsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
#if canImport(UIKit)
import UIKit.UIPasteboard
#elseif canImport(AppKit)
import AppKit.NSPasteboard
#endif

// MARK: - ContainerLogsView+ViewModel

extension ContainerLogsView {
	final class ViewModel: ObservableObject, @unchecked Sendable {
		typealias _ViewState = ViewState<String, Error>

		private let portainerStore = PortainerStore.shared

		private var fetchTask: Task<Void, Never>?
		private var parseTask: Task<Void, Never>?

		@Published @MainActor private(set) var viewState: _ViewState = .loading
		@Published @MainActor private(set) var logsParsed: AttributedString?

		let containerNavigationItem: ContainerNavigationItem

		@Published var includeTimestamps = false
		@Published var lineCount = 100

		@MainActor
		var logsViewable: AttributedString? {
			if let logsParsed { return logsParsed }
			if let logs = viewState.unwrappedValue { return AttributedString(stringLiteral: ANSIParser.trim(logs)) }
			return nil
		}

		init(containerNavigationItem: ContainerNavigationItem) {
			self.containerNavigationItem = containerNavigationItem
		}

		@discardableResult
		func getLogs(errorHandler: ErrorHandler) -> Task<Void, Never> {
			fetchTask?.cancel()
			let task = Task { @MainActor in
				self.viewState = viewState.reloadingUnwrapped
				self.parseTask?.cancel()

				do {
					let logs = try await portainerStore.getLogs(for: containerNavigationItem.id,
																tail: lineCount,
																timestamps: includeTimestamps)
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
