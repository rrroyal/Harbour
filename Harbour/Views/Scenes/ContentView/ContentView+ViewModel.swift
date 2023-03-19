//
//  ContentView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
import UIKit
import PortainerKit

// MARK: - ContentView+ViewModel

extension ContentView {
	@MainActor
	final class ViewModel: ObservableObject {
		private let portainerStore = PortainerStore.shared
		private let preferences = Preferences.shared

		@Published private(set) var fetchTask: Task<Void, Error>?
		@Published private(set) var isLoading = false
		@Published private(set) var error: Error?
		@Published var searchFilter = ""
		@Published var isLandingSheetPresented = !Preferences.shared.landingDisplayed

		var sceneErrorHandler: SceneDelegate.ErrorHandler?

		var viewState: ViewState {
			if !portainerStore.containers.isEmpty {
				return .hasContainers
			}
			if isLoading {
				return .loading
			}
			if let error {
				return .error(error)
			}
			if portainerStore.containers.isEmpty {
				return .containersEmpty
			}
			if portainerStore.serverURL == nil {
				return .noServer
			}
			if portainerStore.selectedEndpoint == nil {
				return .noEndpointSelected
			}
			if portainerStore.endpoints.isEmpty {
				return .noEndpoints
			}
			return .somethingWentWrong
		}

		var shouldUseColumns: Bool {
			guard UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac else {
				return false
			}
			return preferences.cvUseColumns
		}

		var navigationTitle: String {
			portainerStore.selectedEndpoint?.name ?? Localizable.ContentView.noEndpointSelected
		}

		var containers: [Container] {
			portainerStore.containers.filtered(query: searchFilter)
		}

		init() {}

		@Sendable
		func refresh() async {
			do {
				let task = portainerStore.refresh()
				try await task.value
			} catch {
				sceneErrorHandler?(error, ._debugInfo())
			}
		}

		@MainActor
		func onLandingDismissed() {
			preferences.landingDisplayed = true
		}

		@MainActor
		func selectEndpoint(_ endpoint: Endpoint?) {
			portainerStore.selectEndpoint(endpoint)
		}
	}
}

// MARK: - ContentView.ViewModel+ViewState

extension ContentView.ViewModel {
	enum ViewState: Identifiable, Equatable {
		case somethingWentWrong
		case error(Error)
		case loading
		case hasContainers
		case containersEmpty
		case noEndpointSelected
		case noEndpoints
		case noServer

		var id: Int {
			switch self {
				case .somethingWentWrong:	return -2
				case .error:				return -1
				case .loading:				return 0
				case .hasContainers:		return 1
				case .containersEmpty:		return 2
				case .noEndpointSelected:	return 3
				case .noEndpoints:			return 4
				case .noServer:				return 5
			}
		}

		var title: String? {
			switch self {
				case .loading:
					return Localizable.Generic.loading
				case .error(let error):
					return error.localizedDescription
				case .hasContainers:
					return nil
				case .containersEmpty:
					return Localizable.ContainersView.noContainersPlaceholder
				case .noEndpointSelected:
					return Localizable.ContainersView.noSelectedEndpointPlaceholder
				case .noEndpoints:
					return Localizable.ContainersView.noEndpointsPlaceholder
				case .noServer:
					return Localizable.ContainersView.noSelectedServerPlaceholder
				case .somethingWentWrong:
//					return Localizable.Generic.somethingWentWrong
					return nil
			}
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.id == rhs.id
		}
	}
}
