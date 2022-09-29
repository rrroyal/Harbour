//
//  View+optionalTapGesture.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

extension View {
	@ViewBuilder
	func optionalTapGesture(_ action: (() -> Void)?) -> some View {
		if let action {
			onTapGesture(perform: action)
		} else {
			self
		}
	}
}
