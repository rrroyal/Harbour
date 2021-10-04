//
//  ToolbarTitle.swift
//  Harbour
//
//  Created by royal on 08/08/2021.
//

import SwiftUI

struct ToolbarTitle: ToolbarContent {
	let title: String
	let subtitle: String?
	
	var body: some ToolbarContent {
		ToolbarItem(placement: .principal) {
			VStack(spacing: 1) {
				Text(title)
					.font(.headline)
					.fixedSize(horizontal: true, vertical: true)
					.transition(.move(edge: .bottom))
				
				if let subtitle = subtitle {
					Text(subtitle)
						.font(.footnote)
						.opacity(Globals.Views.secondaryOpacity)
						.fixedSize(horizontal: true, vertical: true)
						.transition(.move(edge: .bottom).combined(with: .opacity))
				}
			}
			.animation(.easeInOut, value: subtitle)
		}
	}
}

