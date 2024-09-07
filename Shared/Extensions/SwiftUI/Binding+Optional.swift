//
//  Binding+Optional.swift
//  Harbour
//
//  Created by royal on 17/08/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension Binding {
	static func ?? <Wrapped: Sendable>(optional: Self, defaultValue: Wrapped) -> Binding<Wrapped> where Value == Wrapped? {
		.init(
			get: { optional.wrappedValue ?? defaultValue },
			set: { optional.wrappedValue = $0 }
		)
	}
}
