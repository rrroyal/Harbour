//
//  String+.swift
//  Harbour
//
//  Created by royal on 12/06/2021.
//

import Foundation

extension String {
	func capitalizingFirstLetter() -> String {
		return prefix(1).capitalized + dropFirst()
	}
}
