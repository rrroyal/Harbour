//
//  PortainerStore+TasksController.swift
//  Harbour
//
//  Created by royal on 13/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension PortainerStore {
	final class TasksController: Sendable {
		nonisolated(unsafe) var endpoints: Task<[Endpoint], Error>?
		nonisolated(unsafe) var containers: Task<[Container], Error>?
		nonisolated(unsafe) var stacks: Task<[Stack], Error>?
	}
}
