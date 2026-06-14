//
//  IntentPortainerStore.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonOSLog
import Foundation
import KeychainKit
import OSLog
import PortainerKit

private let logger = Logger(.custom(IntentPortainerStore.self))

// MARK: - IntentPortainerStore

public final class IntentPortainerStore: @unchecked Sendable {
	public let portainer = PortainerClient(urlSessionConfiguration: .intents)
	private let preferences = Preferences()

	public func setupIfNeeded() async throws {
		guard let url = preferences.selectedServer else {
			logger.warning("No selectedServer!")
			throw PortainerError.noServer
		}
		if portainer.serverURL == url { return }

		let token = try Keychain.shared.getString(for: url)
		portainer.serverURL = url
		portainer.token = token
	}
}
