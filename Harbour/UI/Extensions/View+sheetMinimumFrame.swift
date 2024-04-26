//
//  View+sheetMinimumFrame.swift
//  Harbour
//
//  Created by royal on 26/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@available(macOS 14.0, *)
	@ViewBuilder
	func sheetMinimumFrame(width: Double = 360, height: Double = 420) -> some View {
		self
			.frame(minWidth: width, minHeight: height)
	}
}
