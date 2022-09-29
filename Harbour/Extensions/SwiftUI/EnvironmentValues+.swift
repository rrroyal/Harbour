//
//  EnvironmentValues+.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import IndicatorsKit

 extension EnvironmentValues {
	private struct SceneErrorHandler: EnvironmentKey {
		static let defaultValue: SceneState.ErrorHandler? = nil
	}

	var sceneErrorHandler: SceneState.ErrorHandler? {
		get { self[SceneErrorHandler.self] }
		set { self[SceneErrorHandler.self] = newValue }
	}
 }

// MARK: - ContainersListUseGrid

extension EnvironmentValues {
	private struct ContainersViewUseGrid: EnvironmentKey {
		static let defaultValue: Bool = false
	}

	var containersViewUseGrid: Bool {
		get { self[ContainersViewUseGrid.self] }
		set { self[ContainersViewUseGrid.self] = newValue }
	}
}
