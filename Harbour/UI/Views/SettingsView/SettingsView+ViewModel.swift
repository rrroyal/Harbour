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

		var scrollPosition: SettingsView.ViewID?

		var isSetupSheetPresented = false
		var isNegraSheetPresented = false
		var serverURLs: [URL]

		var activeURL: URL?

		var isRemoveEndpointAlertVisible = false
		var endpointToRemove: URL?

		var isNegraButtonVisible = Int.random(in: 0...19) == 11

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
			Task { @MainActor in
				activeURL = portainerStore.serverURL
				serverURLs = portainerStore.savedURLs
			}
		}

		func switchPortainerServer(to serverURL: URL, errorHandler: ErrorHandler?) {
			Task {
				await AppState.shared.switchPortainerServer(to: serverURL, errorHandler: errorHandler)
			}
			Task { @MainActor in
				activeURL = serverURL
			}
		}

		func removeServer(_ url: URL) throws {
			try portainerStore.removeServer(url)
			refreshServers()

			if portainerStore.serverURL == url {
				Task {
					await portainerStore.reset()
				}
				Task { @MainActor in
					activeURL = nil
				}
			}
		}
	}
}
