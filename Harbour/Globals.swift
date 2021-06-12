//
//  Globals.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import SwiftUI

struct Globals {
	enum Views {
		static let cornerRadius: CGFloat = 12
		static let largeCornerRadius: CGFloat = 18

		static let secondaryOpacity: Double = 0.3
		static let candyOpacity: Double = 0.12
		
		static let springAnimation = Animation.interpolatingSpring(stiffness: 250, damping: 30)
	}
	
	enum Buttons {
		static let pressedOpacity: Double = 0.75
		static let pressedSize: CGFloat = 0.975
	}
}
