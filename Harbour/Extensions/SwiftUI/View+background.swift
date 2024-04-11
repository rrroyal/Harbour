//
//  View+background.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@ViewBuilder
	func background<S, F>(
		viewState: ViewState<S, F>,
		backgroundVisiblity: Visibility = .hidden,
		backgroundColor: Color = .clear
	) -> some View {
		self
			.scrollContentBackground(backgroundVisiblity)
			.background(viewState.backgroundView)
			.background(backgroundColor, ignoresSafeAreaEdges: .all)
	}
}
