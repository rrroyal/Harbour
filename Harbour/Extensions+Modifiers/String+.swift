//
//  String+.swift
//  Harbour
//
//  Created by royal on 12/06/2021.
//

import Foundation

extension String {
	func capitalizingFirstLetter() -> String {
		prefix(1).capitalized + dropFirst()
	}

	var isReallyEmpty: Bool {
		trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
	
	var localized: String {
		NSLocalizedString(self, comment: "")
	}
}
