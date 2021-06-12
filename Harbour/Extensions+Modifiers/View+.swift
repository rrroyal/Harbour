//
//  View+.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

// MARK: View+

extension View {
	@ViewBuilder
	func hidden(_ hidden: Bool) -> some View {
		if hidden {
			self.hidden()
		} else {
			self
		}
	}

	func padding(_ edges: Edge.Set, _ length: PaddingSize) -> some View {
		self.padding(edges, length.rawValue)
	}

	func padding(_ size: PaddingSize) -> some View {
		self.padding(size.rawValue)
	}
}

// MARK: PaddingSize

enum PaddingSize: Double {
	case small = 5
	case medium = 13
}
