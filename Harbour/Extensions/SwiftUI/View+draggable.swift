//
//  View+draggable.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//  Copyright © 2023 shameful. All rights reserved.
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
