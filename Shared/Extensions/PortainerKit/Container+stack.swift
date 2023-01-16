//
//  Container+stack.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//

import Foundation
import PortainerKit

extension Container {
	private static let stackLabelID = "com.docker.compose.project"

	var stack: String? {
		labels?.first(where: { $0.key == Self.stackLabelID })?.value
	}
}
