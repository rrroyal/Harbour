//
//  Constants.swift
//  Harbour
//
//  Created by royal on 29/07/2022.
//

import Foundation
import SwiftUI

enum Constants {
	enum Buttons {
		static let pressedOpacity: Double = 0.6
		static let pressedScale: Double = 0.975
		static let pressAnimation: Animation = .interpolatingSpring(stiffness: 250, damping: 30)
	}

	enum ContainerCell {
		static let cornerRadius: Double = 18
		static let circleSize: Double = 8
	}

	static let cornerRadius: Double = 14
	static let secondaryOpacity: Double = 0.3
}
