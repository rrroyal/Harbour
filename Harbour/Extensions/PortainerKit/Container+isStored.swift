//
//  Container+isStored.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import Foundation
import PortainerKit

extension Container {
	// TODO: Validate that every container has those two properties set.
	var isStored: Bool {
		imageID == nil && created == nil
	}
}
