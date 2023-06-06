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
		@Published var searchText = ""
		@Published var isLandingSheetPresented = !Preferences.shared.landingDisplayed

		var errorHandler: ErrorHandler?

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
			portainerStore.containers.filtered(searchText)
		}

		init() {}

		@Sendable
		func refresh() async {
			do {
				let task = portainerStore.refresh()
				try await task.value
			} catch {
				errorHandler?(error)
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
			case .somethingWentWrong:	-2
			case .error:				-1
			case .loading:				0
			case .hasContainers:		1
			case .containersEmpty:		2
			case .noEndpointSelected:	3
			case .noEndpoints:			4
			case .noServer:				5
			}
		}

		var title: String? {
			switch self {
			case .loading:
				Localizable.Generic.loading
			case .error(let error):
				error.localizedDescription
			case .hasContainers:
				nil
			case .containersEmpty:
				Localizable.ContainersView.noContainersPlaceholder
			case .noEndpointSelected:
				Localizable.ContainersView.noSelectedEndpointPlaceholder
			case .noEndpoints:
				Localizable.ContainersView.noEndpointsPlaceholder
			case .noServer:
				Localizable.ContainersView.noSelectedServerPlaceholder
			case .somethingWentWrong:
				nil
			}
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.id == rhs.id
		}
	}
}
