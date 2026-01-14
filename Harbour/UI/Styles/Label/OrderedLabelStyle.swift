//
//  OrderedLabelStyle.swift
//  Harbour
//
//  Created by royal on 14/01/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

struct OrderedLabelStyle: LabelStyle {
	enum Order {
		case iconLabel
		case labelIcon
	}

	let order: Order

	func makeBody(configuration: Configuration) -> some View {
		HStack {
			switch order {
			case .iconLabel:
				configuration.icon
				configuration.title
			case .labelIcon:
				configuration.title
				configuration.icon
			}
		}
	}
}

extension LabelStyle where Self == OrderedLabelStyle {
	static func ordered(_ order: OrderedLabelStyle.Order) -> Self {
		.init(order: order)
	}
}
