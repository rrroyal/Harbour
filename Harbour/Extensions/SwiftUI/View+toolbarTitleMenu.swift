//
//  View+toolbarTitleMenu.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func toolbarTitleMenu<C: View>(isVisible: Bool, @ViewBuilder content: () -> C) -> some View {
		if isVisible {
			toolbarTitleMenu(content: content)
		} else {
			self
		}
	}
}
