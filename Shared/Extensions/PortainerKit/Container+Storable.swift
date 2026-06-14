//
//  Container+init.swift
//  Harbour
//
//  Created by royal on 12/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension Container: Storable {
	typealias Stored = StoredContainer

	static func fromStored(_ stored: Stored) -> Self {
		let names: [String]? = if let name = stored.name {
			["/" + name]
		} else {
			nil
		}

		let labels: [String: String]? = if let associationID = stored.associationID {
			[ContainerLabel.associationID: associationID]
		} else {
			nil
		}

		return self.init(
			id: stored.id,
			names: names,
			image: stored.image,
			labels: labels,
			state: stored.lastState
		)
	}

	func toStored() -> Stored {
		Stored(
			id: self.id,
			name: self.displayName,
			lastState: self.state,
			image: self.image,
			associationID: self.associationID,
			persistentID: self._persistentID
		)
	}
}
