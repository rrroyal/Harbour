//
//  Array+.swift
//  Harbour
//
//  Created by royal on 14/01/2022.
//

import Foundation
import PortainerKit

extension Array where Element == PortainerKit.Container {
	func groupedByStack() -> [ContainersView.ContainersStack] {
		let containers = sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" })
		let sorted = Dictionary(grouping: containers, by: \.stack).sorted(by: {
			guard let a = $0.key else { return false }
			guard let b = $1.key else { return a > $1.key ?? "" }
			return a < b
		})
		return sorted.map { .init(stack: $0.key, containers: $0.value) }
	}
}
