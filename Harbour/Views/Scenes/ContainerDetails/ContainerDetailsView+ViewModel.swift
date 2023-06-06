//
//  ContainerDetailsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
import CoreSpotlight
import PortainerKit

// MARK: - ContainerDetailsView+ViewModel

extension ContainerDetailsView {
	@MainActor
	final class ViewModel: ObservableObject, @unchecked Sendable {
		private let portainerStore = PortainerStore.shared

		@Published private(set) var fetchTask: Task<Void, Never>?
		@Published private(set) var isLoading = false
		@Published private(set) var error: Error?
		@Published private(set) var container: Container?
		@Published private(set) var containerDetails: ContainerDetails?

		var viewState: ViewState {
			if isLoading {
				return .loading
			}
			if containerDetails != nil {
				return .hasDetails
			}
			if let error, !error.isCancellationError {
				return .error(error)
			}
			return .somethingWentWrong
		}

		init() { }

		func createUserActivity(for navigationItem: ContainerNavigationItem,
								userActivity: NSUserActivity,
								errorHandler: ErrorHandler) {
			typealias Localization = Localizable.ContainerDetailsView.UserActivity

			let identifier = "\(HarbourUserActivityIdentifier.containerDetails).\(navigationItem.endpointID ?? -1).\(navigationItem.id)"

			let container = self.container(for: navigationItem)

			userActivity.isEligibleForHandoff = true
			userActivity.isEligibleForPrediction = false
			userActivity.isEligibleForSearch = true

			let displayName = navigationItem.displayName ?? navigationItem.id
			userActivity.title = displayName
//			userActivity.suggestedInvocationPhrase = Localization.title(displayName)

			let attributeSet = CSSearchableItemAttributeSet()
			attributeSet.title = displayName
			attributeSet.contentDescription = Localization.title(displayName)
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

		@discardableResult
		func getContainerDetails(navigationItem: ContainerNavigationItem, errorHandler: ErrorHandler) -> Task<Void, Never> {
			fetchTask?.cancel()
			let task = Task {
				isLoading = true
				container = container(for: navigationItem)

				do {
					if navigationItem.id != containerDetails?.id {
						containerDetails = nil
					}

					if !portainerStore.isSetup {
						await portainerStore.setupTask?.value
					}

					containerDetails = try await portainerStore.inspectContainer(navigationItem.id,
																				 endpointID: navigationItem.endpointID)
				} catch {
					errorHandler(error)
				}

				isLoading = false
			}
			self.fetchTask = task
			return task
		}

		func container(for navigationItem: ContainerNavigationItem) -> Container? {
			if self.container?.id == navigationItem.id { return self.container }
			return portainerStore.containers.first { $0.id == navigationItem.id }
		}
	}
}

// MARK: - ContainerDetailsView.ViewModel+ViewState

extension ContainerDetailsView.ViewModel {
	enum ViewState: Identifiable, Equatable {
		case somethingWentWrong
		case error(Error)
		case loading
		case hasDetails

		var id: Int {
			switch self {
			case .somethingWentWrong:	-2
			case .error:				-1
			case .loading:				0
			case .hasDetails:			1
			}
		}

		var title: String? {
			switch self {
			case .loading:
				Localizable.Generic.loading
			case .error(let error):
				error.localizedDescription
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
