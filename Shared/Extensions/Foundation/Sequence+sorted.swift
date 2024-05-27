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
		sorted {
			comparator($0[keyPath: keyPath], $1[keyPath: keyPath])
		}
	}

	func localizedSorted(
		by keyPath: KeyPath<Element, String>,
		using comparisionResult: ComparisonResult = .orderedAscending
	) -> [Element] {
		sorted {
			$0[keyPath: keyPath].localizedStandardCompare($1[keyPath: keyPath]) == comparisionResult
		}
	}
}

extension Sequence where Element == String {
	func localizedSorted(
		using comparisionResult: ComparisonResult = .orderedAscending
	) -> [Element] {
		sorted {
			$0.localizedStandardCompare($1) == comparisionResult
		}
	}
}
