//
//  SettingsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 01/02/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonOSLog
import Foundation
import IndicatorsKit
import OSLog
#if canImport(UIKit)
import UIKit.UIDevice
#endif
import WidgetKit

// MARK: - SettingsView+ViewModel

extension SettingsView {
	@Observable @MainActor
	final class ViewModel: IndicatorPresentable {
		private let portainerStore: PortainerStore
		private let appState: AppState

		let logger = Logger(.settings)
		let indicators = Indicators()

		let isNegraButtonVisible = Int.random(in: 0...19) == 11

		var scrollPosition: SettingsView.ViewID?

		var isSetupSheetPresented = false
		var isNegraSheetPresented = false
		var serverURLs: [URL]

		var activeURL: URL?

		var isRemoveEndpointAlertPresented = false
		var endpointToRemove: URL?

		init(portainerStore: PortainerStore, appState: AppState) {
			self.portainerStore = portainerStore
			self.appState = appState
			serverURLs = portainerStore.savedURLs
			activeURL = portainerStore.serverURL
		}

		@MainActor
		func refreshServers() {
			activeURL = portainerStore.serverURL
			serverURLs = portainerStore.savedURLs
		}

		@MainActor
		func switchPortainerServer(to serverURL: URL) async throws {
			activeURL = serverURL
			appState.switchPortainerServer(to: serverURL)

			WidgetCenter.shared.reloadAllTimelines()
		}

		@MainActor
		func removeServer(_ url: URL) throws {
			try portainerStore.removeServer(url)
			refreshServers()

			if portainerStore.serverURL == url {
				portainerStore.reset()
				activeURL = nil
			}
		}
	}
}
