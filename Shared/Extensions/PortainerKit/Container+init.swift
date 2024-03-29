//
//  Container+init.swift
//  Harbour
//
//  Created by royal on 12/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Container {
	init(storedContainer: StoredContainer) {
		let names: [String]? = if let name = storedContainer.name {
			["/" + name]
		} else {
			nil
		}

		let labels: [String: String]? = if let associationID = storedContainer.associationID {
			[ContainerLabel.associationID: associationID]
		} else {
			nil
		}

		self.init(
			id: storedContainer.id,
			names: names,
			image: storedContainer.image,
			labels: labels,
			state: storedContainer.lastState
		)
	}
}
