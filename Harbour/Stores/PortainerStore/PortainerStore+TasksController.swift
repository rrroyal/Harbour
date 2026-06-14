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
	final class TasksController {
		var endpoints: Task<[Endpoint], Error>?
		var containers: Task<[Container], Error>?
		var stacks: Task<[Stack], Error>?
	}
}
