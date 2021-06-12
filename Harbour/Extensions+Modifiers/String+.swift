//
//  String+.swift
//  Harbour
//
//  Created by royal on 12/06/2021.
//

import Foundation

extension String {
	func capitalizingFirstLetter() -> String {
		self.prefix(1).capitalized + self.dropFirst()
	}

	var isReallyEmpty: Bool {
		self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
}
