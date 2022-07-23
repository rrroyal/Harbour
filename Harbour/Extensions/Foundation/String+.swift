//
//  String+.swift
//  Harbour
//
//  Created by royal on 18/07/2022.
//

import Foundation

// MARK: - String+isReallyEmpty

extension String {
	var isReallyEmpty: Bool {
		trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
}

extension Optional where Wrapped == String {
	var isReallyEmpty: Bool {
		self?.isReallyEmpty ?? true
	}
}
