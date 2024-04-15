//
//  Stack+init.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Stack {
	init(storedStack: StoredStack) {
		self.init(
			id: storedStack.id,
			name: storedStack.name,
			type: storedStack.type,
			endpointID: storedStack.endpointID,
			env: nil,
			status: nil
		)
	}
}
