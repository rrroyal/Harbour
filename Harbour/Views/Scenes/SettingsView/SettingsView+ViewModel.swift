//
//  SettingsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 01/02/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import Observation
#if canImport(UIKit)
import UIKit.UIDevice
#endif

// MARK: - SettingsView+ViewModel

extension SettingsView {
	@Observable
	final class ViewModel {
		private let portainerStore: PortainerStore = .shared
		private let appState: AppState = .shared

		var isSetupSheetPresented = false
		var serverURLs: [URL]

		var activeURL: URL?

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
			serverURLs = portainerStore.savedURLs
			activeURL = portainerStore.serverURL
		}

		func switchPortainerServer(to serverURL: URL, errorHandler: ErrorHandler?) {
			Task { @MainActor in
				activeURL = serverURL
				appState.switchPortainerServer(to: serverURL, errorHandler: errorHandler)
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
