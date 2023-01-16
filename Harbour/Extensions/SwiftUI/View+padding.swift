//
//  View+padding.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

enum ViewPaddingSize: Double {
	case small = 5
	case medium = 12
	case large = 18
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
