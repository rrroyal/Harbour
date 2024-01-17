//
//  EnvironmentValues+.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import IndicatorsKit
import KeychainKit
import OSLog
import PortainerKit
import SwiftUI

// MARK: - ErrorHandler

extension EnvironmentValues {
	private struct ErrorHandlerEnvironmentKey: EnvironmentKey {
		static let defaultValue: ErrorHandler = .init { error, _debugInfo in
//			assertionFailure("`errorHandler` has been called, but none is attached!")
			os_log(.error, log: .default, "Error: \(error, privacy: .public) [\(_debugInfo, privacy: .public)]")
		}
	}

	/// An action that can handle provided error.
	var errorHandler: ErrorHandler {
		get { self[ErrorHandlerEnvironmentKey.self] }
		set { self[ErrorHandlerEnvironmentKey.self] = newValue }
	}
}

// MARK: - ShowIndicator

extension EnvironmentValues {
	private struct ShowIndicatorEnvironmentKey: EnvironmentKey {
		static let defaultValue: SceneState.ShowIndicatorAction = { indicator in
			assertionFailure("`showIndicator` has been called, but none is attached! Indicator: \(indicator)")
		}
	}

	/// An action that shows provided indicator.
	var showIndicator: SceneState.ShowIndicatorAction {
		get { self[ShowIndicatorEnvironmentKey.self] }
		set { self[ShowIndicatorEnvironmentKey.self] = newValue }
	}
}

// MARK: - Logger

extension EnvironmentValues {
	private struct LoggerEnvironmentKey: EnvironmentKey {
		static let defaultValue = Logger(.app)
	}

	/// Logging subsystem attached to this view.
	var logger: Logger {
		get { self[LoggerEnvironmentKey.self] }
		set { self[LoggerEnvironmentKey.self] = newValue }
	}
}

// MARK: - PortainerServerURL

extension EnvironmentValues {
	private struct PortainerServerURL: EnvironmentKey {
		static let defaultValue: URL? = nil
	}

	/// Active Portainer server URL.
	var portainerServerURL: URL? {
		get { self[PortainerServerURL.self] }
		set { self[PortainerServerURL.self] = newValue }
	}
}

// MARK: - PortainerSelectedEndpointID

extension EnvironmentValues {
	private struct PortainerSelectedEndpoint: EnvironmentKey {
		static let defaultValue: Endpoint.ID? = nil
	}

	/// Active Portainer endpoint ID.
	var portainerSelectedEndpointID: Endpoint.ID? {
		get { self[PortainerSelectedEndpoint.self] }
		set { self[PortainerSelectedEndpoint.self] = newValue }
	}
}

// MARK: - CVUseGrid

extension EnvironmentValues {
	private struct CVUseGrid: EnvironmentKey {
		static let defaultValue: Bool = Preferences.shared.cvUseGrid
	}

	/// `ContainersView` uses grid style view.
	var cvUseGrid: Bool {
		get { self[CVUseGrid.self] }
		set { self[CVUseGrid.self] = newValue }
	}
}
