//
//  SettingsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 01/02/2023.
//

import Foundation
#if canImport(UIKit)
import UIKit.UIDevice
#endif

// MARK: - SettingsView+ViewModel

extension SettingsView {
	@MainActor
	final class ViewModel: ObservableObject {
		private let portainerStore: PortainerStore = .shared
		private let appState: AppState = .shared

		@Published var isSetupSheetPresented = false
		@Published var serverURLs: [URL]

		@Published var activeURL: URL?

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

		func refreshServers() {
			serverURLs = portainerStore.savedURLs
			activeURL = portainerStore.serverURL
		}

		func switchPortainerServer(to serverURL: URL, errorHandler: ErrorHandler?) {
			activeURL = serverURL
			appState.switchPortainerServer(to: serverURL, errorHandler: errorHandler)
		}

		func removeServer(_ url: URL, errorHandler: ErrorHandler?) {
			do {
				if portainerStore.serverURL == url {
					activeURL = nil
					portainerStore.reset()
				}

				try portainerStore.removeServer(url)
				refreshServers()
			} catch {
				errorHandler?(error, ._debugInfo())
			}
		}
	}
}
