//
//  Collection+safe.swift
//  Harbour
//
//  Created by royal on 11/06/2023.
//

import Foundation

extension Collection {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}
