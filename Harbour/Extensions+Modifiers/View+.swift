//
//  View+.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

extension View {
	@ViewBuilder
	func hidden(_ hidden: Bool) -> some View {
		if hidden {
			self.hidden()
		} else {
			self
		}
	}
}
