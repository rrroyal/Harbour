//
//  ContainerDetailsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonOSLog
import CoreSpotlight
import Foundation
import Observation
import OSLog
import PortainerKit

// MARK: - ContainerDetailsView+ViewModel

extension ContainerDetailsView {
	@Observable @MainActor
	final class ViewModel {
		private let portainerStore: PortainerStore = .shared
		private let logger = Logger(.view(ContainerDetailsView.self))

		private(set) var fetchTask: Task<Void, Error>?

		var viewState: ViewState<ContainerDetails, Error> = .loading

		var navigationItem: ContainerDetailsView.NavigationItem

		var scrollViewIsRefreshing = false

		var container: Container? {
			portainerStore.containers.first { $0.id == navigationItem.id }
		}

		var containerDetails: ContainerDetails? {
			viewState.value
		}

		var isStatusProgressViewVisible: Bool {
			!scrollViewIsRefreshing && viewState.showAdditionalLoadingView
		}

		init(navigationItem: ContainerDetailsView.NavigationItem) {
			self.navigationItem = navigationItem
			self.viewState = self.viewState.reloading
		}

		@MainActor
		func createUserActivity(_ userActivity: NSUserActivity, for container: Container?) {
			userActivity.isEligibleForHandoff = true
			userActivity.isEligibleForSearch = false
			#if os(iOS)
			userActivity.isEligibleForPrediction = false
			#endif

//			let displayName = navigationItem.displayName ?? navigationItem.id
//			userActivity.title = String(localized: "UserActivity.ContainerDetails.Title Name:\(displayName)")
			userActivity.title = navigationItem.displayName
//			userActivity.suggestedInvocationPhrase = Localization.title(displayName)

			let attributeSet = CSSearchableItemAttributeSet()
			attributeSet.contentType = HarbourItemType.container
//			attributeSet.title = String(localized: "UserActivity.ContainerDetails.Title Name:\(displayName)")
			attributeSet.title = navigationItem.displayName
//			attributeSet.contentDescription = String(localized: "UserActivity.ContainerDetails.Description Name:\(displayName)")
			attributeSet.contentDescription = navigationItem.id

			userActivity.contentAttributeSet = attributeSet

			if let serverURL = portainerStore.serverURL,
			   let endpointID = navigationItem.endpointID {
				let portainerDeeplink = PortainerDeeplink(baseURL: serverURL)
				let portainerURL = portainerDeeplink?.containerURL(containerID: navigationItem.id, endpointID: endpointID)
				userActivity.webpageURL = portainerURL
//				userActivity.referrerURL = portainerURL
			}

			if let containerNames = container?.names, !containerNames.isEmpty {
				userActivity.keywords = Set(containerNames)
			}

			userActivity.persistentIdentifier = HarbourUserActivityIdentifier.containerDetails
			userActivity.targetContentIdentifier = "\(HarbourUserActivityIdentifier.containerDetails).\(navigationItem.endpointID ?? -1).\(navigationItem.id)"

			do {
				try userActivity.setTypedPayload(navigationItem)
				userActivity.requiredUserInfoKeys = [
					ContainerDetailsView.NavigationItem.CodingKeys.id.stringValue
				]
			} catch {
				logger.error("Failed to set payload: \(error.localizedDescription, privacy: .public)")
			}

//			userActivity.becomeCurrent()
		}

		@MainActor @discardableResult
		func refresh() -> Task<Void, Error> {
			fetchTask?.cancel()
			let task = Task {
				self.viewState = viewState.reloading

				do {
					async let _container = portainerStore.refreshContainers(ids: [navigationItem.id]).value.first
					async let _containerDetails = portainerStore.fetchContainerDetails(navigationItem.id, endpointID: navigationItem.endpointID)
					let (_, containerDetails) = try await (_container, _containerDetails)

					guard !Task.isCancelled else { return }
					self.viewState = .success(containerDetails)
				} catch {
					guard !error.isCancellationError else { return }
					viewState = .failure(error)
					throw error
				}
			}
			self.fetchTask = task
			return task
		}
	}
}
