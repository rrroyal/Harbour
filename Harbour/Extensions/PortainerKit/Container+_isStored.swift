//
//  Container+isStored.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - Container+_isStored

extension Container {
	var _isStored: Bool {
		imageID == nil
	}
}
