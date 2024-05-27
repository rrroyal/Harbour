//
//  Container+preview.swift
//  Harbour
//
//  Created by royal on 19/01/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Container {
	static func preview(name: String = "PreviewContainer", state: Container.State = .running) -> Self {
		self.init(
			id: "preview",
			names: [name],
			image: "preview@latest",
			imageID: "1234",
			command: nil,
			created: Date.now,
			ports: nil,
			labels: nil,
			state: state,
			status: "Running (5 days)",
			mounts: nil
		)
	}
}
