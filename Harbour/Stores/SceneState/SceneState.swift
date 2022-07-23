//
//  SceneState.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation
import os.log
import PortainerKit
import Indicators

final class SceneState: ObservableObject {
	// swiftlint:disable:next force_unwrapping
	internal let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SceneState")

	public let id: String
	public let indicators: Indicators = Indicators()

	@Published public var isSettingsSheetPresented: Bool = false

	@Published public var navigationPath: [Container.ID] = []

	init(id: String = UUID().uuidString) {
		self.id = id
	}
}
