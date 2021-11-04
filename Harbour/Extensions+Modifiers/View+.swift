//
//  View+.swift
//  Harbour
//
//  Created by royal on 04/11/2021.
//

import SwiftUI

extension View {
	@ViewBuilder
	func navigationViewStyle(useColumns: Bool) -> some View {
		if useColumns {
			navigationViewStyle(.columns)
		} else {
			navigationViewStyle(.stack)
		}
	}
}
