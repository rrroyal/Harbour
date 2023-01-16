//
//  EnvironmentValues+.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import PortainerKit
import IndicatorsKit

// MARK: - SceneErrorHandler

 extension EnvironmentValues {
	private struct SceneErrorHandler: EnvironmentKey {
		static let defaultValue: SceneDelegate.ErrorHandler? = nil
	}

	var sceneErrorHandler: SceneDelegate.ErrorHandler? {
		get { self[SceneErrorHandler.self] }
		set { self[SceneErrorHandler.self] = newValue }
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
		static let defaultValue = false
	}

	var containersViewUseGrid: Bool {
		get { self[ContainersViewUseGrid.self] }
		set { self[ContainersViewUseGrid.self] = newValue }
	}
}
