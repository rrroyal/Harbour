//
//  View+hidden.swift
//  Harbour
//
//  Created by royal on 29/10/2022.
//

import SwiftUI

public extension View {
	@ViewBuilder @inlinable
	func hidden(_ isHidden: Bool) -> some View {
		if isHidden {
			hidden()
		} else {
			self
		}
	}
}
