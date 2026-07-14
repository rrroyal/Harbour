//
//  View+.swift
//  Harbour
//
//  Created by royal on 15/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@inline(always)
	func fullWidth(alignment: Alignment = .center) -> some View {
		self
			.frame(maxWidth: .infinity, alignment: alignment)
			.contentShape(Rectangle())
	}
}
