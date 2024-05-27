//
//  Stack+preview.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Stack {
	static func preview(name: String = "PreviewStack", status: Stack.Status = .active) -> Self {
		.init(
			id: 0,
			name: name,
			type: .dockerCompose,
			endpointID: 0,
			env: nil,
			status: status
		)
	}
}
