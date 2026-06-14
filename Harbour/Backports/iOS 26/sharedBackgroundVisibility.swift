//
//  sharedBackgroundVisibility.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

extension ToolbarItem {
	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	@ContentBuilder
	func _sharedBackgroundVisibility(_ visibility: Visibility) -> some ToolbarContent {
		if #available(anyAppleOS 26.0, *) {
			self
				.sharedBackgroundVisibility(visibility)
		} else {
			self
		}
	}
}
