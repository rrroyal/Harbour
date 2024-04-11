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
		static let defaultValue: IndicatorPresentable.PresentIndicatorAction = { indicator in
			assertionFailure("`showIndicator` has been called, but none is attached! Indicator: \(indicator)")
		}
	}

	/// An action that presents a provided indicator.
	var presentIndicator: IndicatorPresentable.PresentIndicatorAction {
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
	private struct PortainerServerURLParentShapeEnvironmentKey: EnvironmentKey {
		static let defaultValue: URL? = nil
	}

	/// Active Portainer server URL.
	var portainerServerURL: URL? {
		get { self[PortainerServerURLParentShapeEnvironmentKey.self] }
		set { self[PortainerServerURLParentShapeEnvironmentKey.self] = newValue }
	}
}

// MARK: - PortainerSelectedEndpointID

extension EnvironmentValues {
	private struct PortainerSelectedEndpointParentShapeEnvironmentKey: EnvironmentKey {
		static let defaultValue: Endpoint.ID? = nil
	}

	/// Active Portainer endpoint ID.
	var portainerSelectedEndpointID: Endpoint.ID? {
		get { self[PortainerSelectedEndpointParentShapeEnvironmentKey.self] }
		set { self[PortainerSelectedEndpointParentShapeEnvironmentKey.self] = newValue }
	}
}

// MARK: - CVUseGrid

extension EnvironmentValues {
	private struct CVUseGridParentShapeEnvironmentKey: EnvironmentKey {
		static let defaultValue: Bool = Preferences.shared.cvUseGrid
	}

	/// `ContainersView` uses grid style view.
	var cvUseGrid: Bool {
		get { self[CVUseGridParentShapeEnvironmentKey.self] }
		set { self[CVUseGridParentShapeEnvironmentKey.self] = newValue }
	}
}

// MARK: - ParentShape

extension EnvironmentValues {
	private struct ParentShapeEnvironmentKey: EnvironmentKey {
		static let defaultValue: AnyShape? = nil
	}

	/// Shape of the parent view.
	var parentShape: AnyShape? {
		get { self[ParentShapeEnvironmentKey.self] }
		set { self[ParentShapeEnvironmentKey.self] = newValue }
	}
}

// MARK: - NavigationPath

extension EnvironmentValues {
	private struct NavigationPathEnvironmentKey: EnvironmentKey {
		static let defaultValue = NavigationPath()
	}

	/// `NavigationPath` for this view stack.
	var navigationPath: NavigationPath {
		get { self[NavigationPathEnvironmentKey.self] }
		set { self[NavigationPathEnvironmentKey.self] = newValue }
	}
}
