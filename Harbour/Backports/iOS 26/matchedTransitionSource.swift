//
//  matchedTransitionSource.swift
//  Harbour
//
//  Created by royal on 23/07/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import SwiftUI

#if os(iOS)
extension ToolbarContent {
	@available(anyAppleOS, obsoleted: 26.0, message: "Use the function directly")
	@inline(always)
	@ContentBuilder
	func _matchedTransitionSource(id: some Hashable, in namespace: Namespace.ID) -> some ToolbarContent {
		if #available(anyAppleOS 26.0, *) {
			self
				.matchedTransitionSource(id: id, in: namespace)
		} else {
			self
		}
	}
}
#endif
