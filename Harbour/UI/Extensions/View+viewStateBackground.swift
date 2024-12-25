//
//  View+viewStateBackground.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension View {
	@ViewBuilder
	func viewStateBackground<S, F>(
		_ viewState: ViewState<S, F>,
		isViewStateBackgroundVisible: Bool = true,
		backgroundVisiblity: Visibility = .hidden,
		backgroundColor: Color = .clear
	) -> some View {
		self
			.scrollContentBackground(backgroundVisiblity)
			.background {
				if isViewStateBackgroundVisible {
					viewState.backgroundView
				}
			}
			.background(backgroundColor, ignoresSafeAreaEdges: .all)
	}
}
