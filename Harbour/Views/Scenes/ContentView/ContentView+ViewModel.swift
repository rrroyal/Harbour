//
//  ContentView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import PortainerKit

// MARK: - ContentView+ViewModel

extension ContentView {
	@MainActor
	final class ViewModel: ObservableObject {
		private let portainerStore: PortainerStore
		private let preferences = Preferences.shared

		private var fetchTask: Task<Void, Error>?

		@Published @MainActor private(set) var viewState: ViewState<[Container]?, Error>

		@Published @MainActor var searchText = ""
		@Published @MainActor var isLandingSheetPresented = !Preferences.shared.landingDisplayed

		var containers: [Container]? {
			viewState.unwrappedValue??.filtered(searchText)
		}

		var shouldShowEmptyPlaceholderView: Bool {
			!viewState.isLoading && containers?.isEmpty ?? true
		}

		var shouldUseColumns: Bool {
			#if os(iOS)
			guard UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac else {
				return false
			}
			#endif
			return preferences.cvUseColumns
		}

		var navigationTitle: String {
			portainerStore.selectedEndpoint?.name ?? "ContentView.NoEndpointSelected"
		}

		init() {
			let portainerStore = PortainerStore.shared
			self.portainerStore = portainerStore

			self.viewState = .success(portainerStore.containers)
		}

		@MainActor
		func refresh() async throws {
			do {
				viewState = viewState.reloadingUnwrapped
				let task = portainerStore.refresh()
				let (_, containers) = try await task.value
				viewState = .success(containers)
			} catch {
				viewState = .failure(error)
				throw error
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
