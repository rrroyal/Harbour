//
//  ShapeStyle+disabled.swift
//  Harbour
//
//  Created by royal on 30/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

extension ShapeStyle where Self == HierarchicalShapeStyle {
	static var disabled: Self {
		#if os(iOS)
		.tertiary
		#elseif os(macOS)
		.secondary
		#endif
	}
}
