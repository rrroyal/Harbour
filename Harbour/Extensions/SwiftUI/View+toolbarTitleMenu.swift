//
//  View+toolbarTitleMenu.swift
//  Harbour
//
//  Created by royal on 28/07/2022.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func toolbarTitleMenu<Content: View>(isVisible: Bool, @ViewBuilder content: () -> Content) -> some View {
		if isVisible {
			toolbarTitleMenu(content: content)
		} else {
			self
		}
	}
}
