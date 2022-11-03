//
//  SceneState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation
import SwiftUI
import OSLog
import PortainerKit
import IndicatorsKit

// MARK: - SceneState

@MainActor
public final class SceneState: ObservableObject {

	// MARK: Internal properties

	internal let logger = Logger(category: .sceneState)
	internal let indicators = Indicators()

	// MARK: Public properties

	public let id: String

	// MARK: Navigation

	@Published public var isSettingsSheetPresented = false
	@Published public var navigationPath = NavigationPath()

	// MARK: Data State

	public var isLoading: Bool {
		let portainerStore = PortainerStore.shared
		let setupTask = portainerStore.setupTask != nil
		let endpointsTask = portainerStore.endpointsTask != nil
		let containersTask = portainerStore.containersTask != nil
		return setupTask || endpointsTask || containersTask
	}

	// MARK: init

	init(id: String = UUID().uuidString) {
		self.id = id
	}

}
