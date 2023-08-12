//
//  Container+isStored.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import Foundation
import PortainerKit

// MARK: - Container+_isStored

extension Container {
	var _isStored: Bool {
		imageID == nil
	}
}
