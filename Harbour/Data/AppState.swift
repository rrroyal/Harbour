//
//  AppState.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import os.log

class AppState: ObservableObject {
	public static let shared: AppState = AppState()

	@Published public var showContainerConsoleView: Bool = false
	@Published public var attachedContainerID: String? = nil

	private let logger: Logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier ?? "Harbour").AppState", category: "AppState")

	private init() {}

	public func handle(_ error: Error, fileID: StaticString = #fileID) {
		self.logger.error("\(String(describing: error)) [\(fileID)]")
	}
}
