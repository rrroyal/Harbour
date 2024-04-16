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

		private(set) var fetchTask: Task<Void, Error>?
		private(set) var fetchStackFileTask: Task<Void, Error>?

		private(set) var viewState: ViewState<Stack, Error> = .loading
		private(set) var stackFileViewState: ViewState<String, Error> = .loading

		var navigationItem: StackDetailsView.NavigationItem

		var stack: Stack? {
			viewState.value
		}

		var isRemovingStack = false
		var isStackFileSheetPresented = false
		var isStackRemovalAlertPresented = false

		init(navigationItem: StackDetailsView.NavigationItem) {
			self.navigationItem = navigationItem
		}

		@discardableResult
		func getStack() -> Task<Void, Error> {
			self.fetchTask?.cancel()
			let task = Task<Void, Error> {
				do {
					viewState = viewState.reloading
					stackFileViewState = .loading

					let stackID = Int(navigationItem.stackID) ?? -1
					let stack = try await PortainerStore.shared.fetchStack(id: stackID)
					viewState = .success(stack)
				} catch {
					viewState = .failure(error)
					throw error
				}
			}
			self.fetchTask = task
			return task
		}

		@discardableResult
		func getStackFile() -> Task<Void, Error> {
			self.fetchStackFileTask?.cancel()
			let task = Task<Void, Error> {
				do {
					stackFileViewState = stackFileViewState.reloading

					let stackID = Int(navigationItem.stackID) ?? -1
					let stackFile = try await PortainerStore.shared.fetchStackFile(stackID: stackID)
					stackFileViewState = .success(stackFile)
				} catch {
					stackFileViewState = .failure(error)
					throw error
				}
			}
			self.fetchStackFileTask = task
			return task
		}

		func removeStack() -> Task<Void, Error> {
			Task {
				let stackID = Int(navigationItem.stackID) ?? -1
				try await PortainerStore.shared.removeStack(stackID: stackID)
			}
		}

		func createUserActivity(_ userActivity: NSUserActivity) {
			guard let stack else { return }

			userActivity.isEligibleForHandoff = true
			userActivity.isEligibleForSearch = true
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
