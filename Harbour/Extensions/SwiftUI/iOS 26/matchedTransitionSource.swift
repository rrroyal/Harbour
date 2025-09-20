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
	@ToolbarContentBuilder @inlinable
	func _matchedTransitionSource(id: some Hashable, in namespace: Namespace.ID) -> some ToolbarContent {
		if #available(iOS 26.0, *) {
			self
				.matchedTransitionSource(id: id, in: namespace)
		} else {
			self
		}
	}
}
#endif
