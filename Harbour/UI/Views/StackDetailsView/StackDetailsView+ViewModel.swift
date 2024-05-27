//
//  StackDetailsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonOSLog
import CoreSpotlight
import Foundation
import OSLog
import PortainerKit

extension StackDetailsView {
	@Observable
	final class ViewModel {
		private nonisolated let logger = Logger(.view(StackDetailsView.self))

		private let portainerStore = PortainerStore.shared

		private(set) var fetchTask: Task<Void, Error>?
		private(set) var fetchStackFileTask: Task<Void, Error>?

		private(set) var viewState: ViewState<Stack, Error> = .loading
		private(set) var stackFileViewState: ViewState<String, Error>?

		var navigationItem: StackDetailsView.NavigationItem

		var isRemovingStack = false
		var isRemoveStackAlertPresented = false
		var scrollViewIsRefreshing = false

		var stack: Stack? {
			viewState.value
		}

		var stackFileContent: String? {
			stackFileViewState?.value
		}

		var isFetchingStackFileContent: Bool {
			!(fetchStackFileTask?.isCancelled ?? true) || (stackFileViewState?.isLoading ?? false)
		}

		var isStatusProgressViewVisible: Bool {
			!scrollViewIsRefreshing && viewState.showAdditionalLoadingView && !(fetchTask?.isCancelled ?? true)
		}

		init(navigationItem: StackDetailsView.NavigationItem) {
			self.navigationItem = navigationItem

			if let stack = portainerStore.stacks.first(where: { $0.id == Int(navigationItem.stackID) }) {
				self.viewState = .reloading(stack)
			}
		}

		@discardableResult
		func getStack(stackID: Stack.ID) -> Task<Void, Error> {
			self.fetchTask?.cancel()
			let task = Task<Void, Error> {
				defer { self.fetchTask = nil }

				do {
					viewState = viewState.reloading

					if stackFileContent != nil {
						fetchStackFile()
					}

					let stack = try await portainerStore.fetchStack(id: stackID)
					viewState = .success(stack)
				} catch {
					guard !error.isCancellationError else { return }
					viewState = .failure(error)
					throw error
				}
			}
			self.fetchTask = task
			return task
		}

		@discardableResult
		func fetchStackFile() -> Task<Void, Error> {
			self.fetchStackFileTask?.cancel()
			let task = Task<Void, Error> {
				defer { self.fetchStackFileTask = nil }

				do {
					stackFileViewState = stackFileViewState?.reloading ?? .loading

					let stackID = Int(navigationItem.stackID) ?? -1
					let stackFile = try await portainerStore.fetchStackFile(stackID: stackID)
					stackFileViewState = .success(stackFile)
				} catch {
					guard !error.isCancellationError else { return }
					stackFileViewState = .failure(error)
					throw error
				}
			}
			self.fetchStackFileTask = task
			return task
		}

		func setStackState(_ stack: Stack, started: Bool) async throws {
			let newStack = try await portainerStore.setStackState(stackID: stack.id, started: started)
			if let newStack {
				self.viewState = .success(newStack)
			}
			portainerStore.refreshContainers()
		}

		func removeStack(_ stack: Stack) async throws {
			try await portainerStore.removeStack(stackID: stack.id)
			portainerStore.refreshStacks()
		}

		func createUserActivity(_ userActivity: NSUserActivity) {
			guard let stack else { return }

			userActivity.isEligibleForHandoff = true
			userActivity.isEligibleForSearch = false
			#if os(iOS)
			userActivity.isEligibleForPrediction = false
			#endif

			userActivity.title = stack.name

			let attributeSet = CSSearchableItemAttributeSet()
			attributeSet.contentType = HarbourItemType.stack
			attributeSet.title = stack.name
			attributeSet.contentDescription = stack.id.description

			userActivity.contentAttributeSet = attributeSet

			if let serverURL = PortainerStore.shared.serverURL {
				let portainerDeeplink = PortainerDeeplink(baseURL: serverURL)
				let portainerURL = portainerDeeplink?.stackURL(stack: stack)
				userActivity.webpageURL = portainerURL
//				userActivity.referrerURL = portainerURL
			}

			userActivity.keywords = [stack.name]

			userActivity.persistentIdentifier = HarbourUserActivityIdentifier.containerDetails
			userActivity.targetContentIdentifier = "\(HarbourUserActivityIdentifier.stackDetails).\(stack.endpointID).\(stack.id)"

			do {
				try userActivity.setTypedPayload(navigationItem)
				userActivity.requiredUserInfoKeys = [
					ContainerDetailsView.NavigationItem.CodingKeys.id.stringValue
				]
			} catch {
				logger.error("Failed to set payload: \(error, privacy: .public)")
			}

//			userActivity.becomeCurrent()
		}
	}
}
