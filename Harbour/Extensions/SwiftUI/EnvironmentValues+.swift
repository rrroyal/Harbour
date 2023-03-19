//
//  EnvironmentValues+.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import OSLog
import PortainerKit
import IndicatorsKit

// MARK: - SceneErrorHandler

 extension EnvironmentValues {
	private struct SceneErrorHandler: EnvironmentKey {
		static let defaultValue: SceneDelegate.ErrorHandler = { error, _debugInfo in
			assertionFailure("`SceneErrorHandler` has been called, but none is attached!")
			os_log(.error, log: .default, "Error: \(error, privacy: .public) [\(_debugInfo, privacy: .public)]")
		}
	}

	var sceneErrorHandler: SceneDelegate.ErrorHandler {
		get { self[SceneErrorHandler.self] }
		set { self[SceneErrorHandler.self] = newValue }
	}
 }

// MARK: - ShowIndicatorAction

extension EnvironmentValues {
	private struct ShowIndicatorAction: EnvironmentKey {
		static let defaultValue: SceneDelegate.ShowIndicatorAction = { indicator in
			assertionFailure("`ShowIndicatorAction` has been called, but none is attached! Indicator: \(indicator)")
		}
	}

	var showIndicatorAction: SceneDelegate.ShowIndicatorAction {
		get { self[ShowIndicatorAction.self] }
		set { self[ShowIndicatorAction.self] = newValue }
	}
}

// MARK: - PortainerServerURL

extension EnvironmentValues {
	private struct PortainerServerURL: EnvironmentKey {
		static let defaultValue: URL? = nil
	}

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

	var portainerSelectedEndpointID: Endpoint.ID? {
		get { self[PortainerSelectedEndpoint.self] }
		set { self[PortainerSelectedEndpoint.self] = newValue }
	}
}

// MARK: - ContainersListUseGrid

extension EnvironmentValues {
	private struct ContainersViewUseGrid: EnvironmentKey {
		static let defaultValue = Preferences.shared.cvUseGrid
	}

	var containersViewUseGrid: Bool {
		get { self[ContainersViewUseGrid.self] }
		set { self[ContainersViewUseGrid.self] = newValue }
	}
}
