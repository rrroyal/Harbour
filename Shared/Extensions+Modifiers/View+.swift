//
//  View+.swift
//  Shared
//
//  Created by unitears on 11/06/2021.
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
		padding(edges, length.rawValue)
	}

	func padding(_ size: PaddingSize) -> some View {
		padding(size.rawValue)
	}
}

// MARK: PaddingSize

enum PaddingSize: Double {
	case small = 5
	case medium = 13
}
