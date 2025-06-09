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
			portainerStore.containers.first {
				$0.id == navigationItem.id || (navigationItem.persistentID != nil ? $0._persistentID == navigationItem.persistentID : false)
			}
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

		@discardableResult
		// swiftlint:disable:next cyclomatic_complexity
		func refresh() -> Task<Void, Error> {
			fetchTask?.cancel()
			let task = Task {
				self.viewState = viewState.reloading

				do {
					let containerDetails = try await withThrowingTaskGroup(of: Result<ContainerDetails, Error>.self, returning: ContainerDetails.self) { group in
						let addedTask1: Bool
						let addedTask2: Bool
						nonisolated(unsafe) var containerNotFoundError: Error?

						// Resolve by `navigationItem.id`
						addedTask1 = group.addTaskUnlessCancelled { @Sendable [weak self, navigationItem] in
							guard let self else { throw CancellationError() }

							do {
								self.logger.debug("Started resolving by navigationItem.id: \"\(navigationItem.id)\"...")

								let containerDetails = try await self.portainerStore.fetchContainerDetails(navigationItem.id, endpointID: navigationItem.endpointID)

								guard !Task.isCancelled else { return .failure(CancellationError()) }

								self.logger.notice("Resolved by navigationItem.id: \"\(navigationItem.id)\"")
								return .success(containerDetails)
							} catch {
								// Store the error for user feedback
								containerNotFoundError = error
								self.logger.warning("Failed to resolve ContainerDetails for navigationItem.id: \"\(navigationItem.id)\": \(String(describing: error), privacy: .public)")
								return .failure(error)
							}
						}

						// Resolve by `navigationItem.persistentID`
						if let persistentID = navigationItem.persistentID {
							addedTask2 = group.addTaskUnlessCancelled { [weak self, navigationItem] in
								guard let self else { throw CancellationError() }

								do {
									self.logger.debug("Started resolving by persistentID: \"\(persistentID)\"...")

									// Wait for full refresh
									if let containersTask = await self.portainerStore.containersTask {
										self.logger.debug("Waiting for existing container refresh task")
										_ = try await containersTask.value
									} else {
										self.logger.debug("Starting a new container refresh task...")
										_ = try await self.portainerStore.refreshContainers().value
									}

									// Check if we still have to search
									guard !Task.isCancelled else { return .failure(CancellationError()) }

									// Try to find the container
									guard let persistentContainer = await self.portainerStore.containers.first(where: { $0._persistentID == persistentID }) else {
										self.logger.warning("Didn't find container for persistentID: \"\(persistentID)\"!")
										return .failure(LoadingError.noContainerForPersistentID)
									}

									// Check if we still have to search
									guard !Task.isCancelled else { return .failure(CancellationError()) }

									// Fetch
									let containerDetails = try await self.portainerStore.fetchContainerDetails(persistentContainer.id, endpointID: navigationItem.endpointID)
									guard !Task.isCancelled else { return .failure(CancellationError()) }

									// Return
									self.logger.notice("Resolved by persistentID: \"\(persistentID)\" = \"\(persistentContainer.id)\"")
									return .success(containerDetails)
								} catch {
									self.logger.warning("Failed to resolve ContainerDetails for persistentID: \"\(persistentID)\": \(String(describing: error), privacy: .public)")
									return .failure(LoadingError.noContainerForPersistentID)
								}
							}
						} else {
							addedTask2 = false
						}

						if group.isCancelled || (!addedTask1 && !addedTask2) {
							// Didn't add any task, so the group had to be cancelled
							logger.debug("Didn't add any tasks for resolving!")
							throw CancellationError()
						}

						for try await result in group {
							switch result {
							case .success(let details):
								// If we got details, cancel the group and return them...
								group.cancelAll()
								return details
							case .failure:
								// ...otherwise, we don't care what error happened and we just want to handle it
								break
							}
						}

						// Provide feedback for user
						if let containerNotFoundError {
							throw containerNotFoundError
						}

						// By here we should've returned a value or threw, so if not, resolving _really_ failed
						throw PortainerError.containerNotFound(navigationItem.id)
					}
					viewState = .success(containerDetails)
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

extension ContainerDetailsView.ViewModel {
	enum LoadingError: Error {
		case noContainerForPersistentID
	}
}
