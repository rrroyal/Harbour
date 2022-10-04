//
//  Container+Equatable.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import Foundation
import PortainerKit

extension Container: Equatable {
	public static func == (lhs: PortainerKit.Container, rhs: PortainerKit.Container) -> Bool {
		lhs.id == rhs.id &&
		lhs.names == rhs.names &&
		lhs.state == rhs.state &&
		lhs.status == rhs.status
	}
}
