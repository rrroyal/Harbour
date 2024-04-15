//
//  SettingsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 01/02/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import IndicatorsKit
#if canImport(UIKit)
import UIKit.UIDevice
#endif

// MARK: - SettingsView+ViewModel

extension SettingsView {
	@Observable
	final class ViewModel: IndicatorPresentable {
		private let portainerStore: PortainerStore = .shared

		let indicators = Indicators()

		var isSetupSheetPresented = false
		var isNegraSheetPresented = false
		var serverURLs: [URL]

		var activeURL: URL?

		var isEndpointRemovalAlertPresented = false
		var endpointToDelete: URL?

		var shouldDisplayNegraButton = Int.random(in: 0...19) == 11

		var displayiPadOptions: Bool {
			#if os(macOS)
			true
			#else
			UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad
			#endif
		}

		init() {
			serverURLs = portainerStore.savedURLs
			activeURL = portainerStore.serverURL
		}

		@MainActor
		func refreshServers() {
			activeURL = portainerStore.serverURL
			serverURLs = portainerStore.savedURLs
		}

		func switchPortainerServer(to serverURL: URL, errorHandler: ErrorHandler?) {
			Task { @MainActor in
				activeURL = serverURL
				AppState.shared.switchPortainerServer(to: serverURL, errorHandler: errorHandler)
			}
		}

		func removeServer(_ url: URL) throws {
			Task { @MainActor in
				if portainerStore.serverURL == url {
					activeURL = nil
					portainerStore.reset()
				}

				try portainerStore.removeServer(url)
				refreshServers()
			}
		}
	}
}
