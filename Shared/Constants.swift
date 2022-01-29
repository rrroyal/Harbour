//
//  Constants.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct Constants {
	static let cornerRadius: Double = 14
	static let largeCornerRadius: Double = 18
	
	static let secondaryOpacity: Double = 0.3
	static let candyOpacity: Double = 0.12
	
	static let springAnimation = Animation.interpolatingSpring(stiffness: 250, damping: 30)
	
	static let maxButtonWidth: Double = 600

	static let buttonPressedOpacity: Double = 0.75
	static let buttonPressedSize: Double = 0.975
	
	enum Widgets {
		public static let statusWidgetKind: String = "StatusWidgets"
	}
}
