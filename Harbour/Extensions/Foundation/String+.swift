//
//  String+.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation

// MARK: - String+capitalized

extension String {
	func capitalized() -> Self {
		prefix(1).uppercased() + dropFirst()
	}
}

// MARK: - String+isReallyEmpty

extension String {
	var isReallyEmpty: Bool {
		trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
}

extension String? {
	var isReallyEmpty: Bool {
		self?.isReallyEmpty ?? true
	}
}
