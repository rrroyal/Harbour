//
//  Globals.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import SwiftUI

struct Globals {
	enum Views {
		static let cornerRadius: Double = 14
		static let largeCornerRadius: Double = 18

		static let secondaryOpacity: Double = 0.3
		static let candyOpacity: Double = 0.12

		static let springAnimation = Animation.interpolatingSpring(stiffness: 250, damping: 30)
		
		static let maxButtonWidth: Double = 600
	}

	enum Buttons {
		static let pressedOpacity: Double = 0.75
		static let pressedSize: Double = 0.975
	}
}
