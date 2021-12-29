//
//  UIApplication+.swift
//  Harbour
//
//  Created by Kacper on 29/12/2021.
//

import Foundation
import UIKit

extension UIApplication {
	static let appIcons: [String?] = [ nil, "Dark" ]
	
#if targetEnvironment(macCatalyst)
	static let isMacCatalyst: Bool = true
#else
	static let isMacCatalyst: Bool = false
#endif
}
