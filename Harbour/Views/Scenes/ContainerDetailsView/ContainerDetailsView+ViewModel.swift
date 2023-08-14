//
//  ContainerDetailsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import CoreSpotlight
import Foundation
import Observation
import PortainerKit

// MARK: - ContainerDetailsView+ViewModel

extension ContainerDetailsView {
	@Observable
	final class ViewModel {
		private let portainerStore = PortainerStore.shared

		private(set) var viewState: ViewState<ContainerDetails, Error> = .loading
		private(set) var container: Container?
		private(set) var fetchTask: Task<Void, Never>?

		let navigationItem: ContainerNavigationItem

		var containerDetails: ContainerDetails? {
			viewState.unwrappedValue
		}

		@MainActor
		var navigationTitle: String {
			containerDetails?.displayName ?? navigationItem.displayName ?? container(for: navigationItem)?.displayName ?? navigationItem.id
		}

		init(navigationItem: ContainerNavigationItem) {
			self.navigationItem = navigationItem
		}

		@MainActor
		func createUserActivity(for navigationItem: ContainerNavigationItem,
								userActivity: NSUserActivity,
								errorHandler: ErrorHandler) {
			let identifier = "\(HarbourUserActivityIdentifier.containerDetails).\(navigationItem.endpointID ?? -1).\(navigationItem.id)"

			let container = self.container(for: navigationItem)

			userActivity.isEligibleForHandoff = true
			#if os(iOS)
			userActivity.isEligibleForPrediction = false
			#endif
			userActivity.isEligibleForSearch = true

			let displayName = navigationItem.displayName ?? navigationItem.id
			userActivity.title = String(localized: "UserActivity.ContainerDetails.Title Name:\(displayName)")
//			userActivity.suggestedInvocationPhrase = Localization.title(displayName)

			let attributeSet = CSSearchableItemAttributeSet()
			attributeSet.title = String(localized: "UserActivity.ContainerDetails.Title Name:\(displayName)")
			attributeSet.contentDescription = String(localized: "UserActivity.ContainerDetails.Description Name:\(displayName)")
			userActivity.contentAttributeSet = attributeSet

			if let serverURL = portainerStore.serverURL,
			   let endpointID = navigationItem.endpointID {
				let portainerURLScheme = PortainerURLScheme(address: serverURL)
				let portainerURL = portainerURLScheme?.containerURL(containerID: navigationItem.id, endpointID: endpointID)
				userActivity.webpageURL = portainerURL
//				userActivity.referrerURL = portainerURL
			}

			if let containerNames = container?.names {
				userActivity.keywords = Set(containerNames)
			}

			userActivity.persistentIdentifier = identifier
			userActivity.targetContentIdentifier = identifier

			do {
				try userActivity.setTypedPayload(navigationItem)

				let requiredUserInfoKeys: [String] = [
					ContainerNavigationItem.CodingKeys.id.stringValue
				]
				userActivity.requiredUserInfoKeys = Set(requiredUserInfoKeys)
			} catch {
				errorHandler(error)
			}
		}

		@MainActor @discardableResult
		func getContainerDetails(navigationItem: ContainerNavigationItem, errorHandler: ErrorHandler) -> Task<Void, Never> {
			fetchTask?.cancel()
			let task = Task {
				viewState = viewState.reloadingUnwrapped
				container = container(for: navigationItem)

				do {
					if !portainerStore.isSetup {
						await portainerStore.setupTask?.value
					}

					let containerDetails = try await portainerStore.inspectContainer(navigationItem.id, endpointID: navigationItem.endpointID)
					viewState = .success(containerDetails)
				} catch {
					viewState = .failure(error)
					errorHandler(error)
				}
			}
			self.fetchTask = task
			return task
		}

		@MainActor
		func container(for navigationItem: ContainerNavigationItem) -> Container? {
			if self.container?.id == navigationItem.id { return self.container }
			return portainerStore.containers.first { $0.id == navigationItem.id }
		}
	}
}
