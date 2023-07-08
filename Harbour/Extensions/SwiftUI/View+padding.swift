//
//  View+padding.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// TODO: Check if it's needed

enum ViewPaddingSize: Double {
	case small = 8
	case medium = 10
	case large = 16
}

extension View {
	@ViewBuilder
	func padding(_ edges: Edge.Set, _ size: ViewPaddingSize) -> some View {
		padding(edges, size.rawValue)
	}

	@ViewBuilder
	func padding(_ size: ViewPaddingSize) -> some View {
		padding(size.rawValue)
	}
}
