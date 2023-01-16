//
//  View+draggable.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//

import SwiftUI

extension View {
	@inlinable @ViewBuilder
	func draggable<T: Transferable>(_ payload: T?) -> some View {
		if let payload {
			draggable(payload)
		} else {
			self
		}
	}
}
