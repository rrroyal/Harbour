//
//  SceneState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation
import SwiftUI
import os.log
import PortainerKit
import IndicatorsKit

// MARK: - SceneState

final class SceneState: ObservableObject {

	// MARK: Internal properties

	// swiftlint:disable:next force_unwrapping
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SceneState")

	// MARK: Public properties

	public let id: String
	public let indicators: Indicators = Indicators()

	// MARK: Navigation

	@Published public var isSettingsSheetPresented: Bool = false
	@Published public var navigationPath: NavigationPath = NavigationPath()

	// MARK: Data State

	@Published public var isLoadingMainScreenData: Bool = false

	// MARK: init

	init(id: String = UUID().uuidString) {
		self.id = id
	}
}
