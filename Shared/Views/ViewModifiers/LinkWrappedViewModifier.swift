//
//  LinkWrappedViewModifier.swift
//  Harbour
//
//  Created by royal on 25/12/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

struct LinkWrappedViewModifier: ViewModifier {
	let url: URL?

	func body(content: Content) -> some View {
		if let url {
			Link(destination: url) {
				content
			}
		} else {
			content
		}
	}
}
