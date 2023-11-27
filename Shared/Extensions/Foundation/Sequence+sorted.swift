//
//  Sequence+sorted.swift
//  Harbour
//
//  Created by royal on 12/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

extension Sequence {
	func sorted<T: Comparable>(
		by keyPath: KeyPath<Element, T>,
		using comparator: (T, T) -> Bool = (<)
	) -> [Element] {
		sorted { a, b in
			comparator(a[keyPath: keyPath], b[keyPath: keyPath])
		}
	}
}
