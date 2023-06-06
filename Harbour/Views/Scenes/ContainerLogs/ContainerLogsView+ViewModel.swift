//
//  ContainerLogsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
import UIKit.UIPasteboard

// MARK: - ContainerLogsView+ViewModel

extension ContainerLogsView {
	final class ViewModel: ObservableObject, @unchecked Sendable {
		private let portainerStore = PortainerStore.shared

		let containerNavigationItem: ContainerNavigationItem

		@Published private(set) var fetchTask: Task<Void, Never>?
		@Published private(set) var parseTask: Task<Void, Never>?
		@Published @MainActor private(set) var isLoading = false
		@Published @MainActor private(set) var error: Error?
		@Published @MainActor private(set) var logs: String?
		@Published @MainActor private(set) var logsParsed: AttributedString?
		@Published var includeTimestamps = false
		@Published var linesCount = 100

		@MainActor
		var viewState: ViewState {
			if let logs {
				return logs.isEmpty ? .logsEmpty : .hasLogs
			}
			if isLoading {
				return .loading
			}
			if let error, !error.isCancellationError {
				return .error(error)
			}
			return .somethingWentWrong
		}

		@MainActor
		var logsViewable: AttributedString? {
			if let logsParsed { return logsParsed }
			if let logs { return AttributedString(stringLiteral: ANSIParser.trim(logs)) }
			return nil
		}

		init(containerNavigationItem: ContainerNavigationItem) {
			self.containerNavigationItem = containerNavigationItem
		}

		@discardableResult
		func getLogs(errorHandler: ErrorHandler) -> Task<Void, Never> {
			fetchTask?.cancel()
			let task = Task { @MainActor in
				self.isLoading = true
				self.error = nil
				self.parseTask?.cancel()

				do {
					let logs = try await portainerStore.getLogs(for: containerNavigationItem.id,
																tail: linesCount,
																timestamps: includeTimestamps)
					self.logs = logs
					self.logsParsed = nil

					self.parseTask = Task.detached {
						let logsParsed = ANSIParser.parse(logs)
						await MainActor.run {
							guard !Task.isCancelled else { return }
							self.logsParsed = logsParsed
						}
					}
				} catch {
					errorHandler(error)
					self.logs = nil
					self.error = error
				}

				self.isLoading = false
			}
			self.fetchTask = task
			return task
		}

		func copyLogs(showIndicatorAction: SceneDelegate.ShowIndicatorAction?) {
			Task {
				UIPasteboard.general.string = await logs
				showIndicatorAction?(.copied)
			}
		}
	}
}

// MARK: - ContainerLogsView.ViewModel+ViewState

extension ContainerLogsView.ViewModel {
	enum ViewState: Identifiable, Equatable {
		case somethingWentWrong
		case error(Error)
		case loading
		case hasLogs
		case logsEmpty

		var id: Int {
			switch self {
			case .somethingWentWrong:	-2
			case .error:				-1
			case .loading:				0
			case .hasLogs:				2
			case .logsEmpty:			3
			}
		}

		var title: String? {
			switch self {
			case .loading:
				Localizable.Generic.loading
			case .error(let error):
				error.localizedDescription
			case .logsEmpty:
				Localizable.ContainerLogsView.logsEmpty
			case .somethingWentWrong:
				nil
			default:
				nil
			}
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.id == rhs.id
		}
	}
}
