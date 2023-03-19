//
//  Container+isStored.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import Foundation
import PortainerKit

extension Container {
	var isStored: Bool {
		imageID == nil
	}
}
