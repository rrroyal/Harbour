//
//  AppState+Portainer.swift
//  Harbour
//
//  Created by royal on 29/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import Foundation

extension AppState {
	func switchPortainerServer(to serverURL: URL, errorHandler: ErrorHandler?) {
//		logger.notice("Switching Portainer server to \"\(serverURL.absoluteString, privacy: .sensitive(mask: .hash))\"")

		portainerServerSwitchTask?.cancel()
		portainerServerSwitchTask = Task {
			defer { self.portainerServerSwitchTask = nil }

			let portainerStore = PortainerStore.shared
			do {
				try portainerStore.switchServer(to: serverURL)
				portainerStore.refresh(errorHandler: errorHandler)
			} catch {
				logger.error("Failed to switch Portainer server: \(error, privacy: .public)")
				errorHandler?(error)
				throw error
			}
		}
	}
}
