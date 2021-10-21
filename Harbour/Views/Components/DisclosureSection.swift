//
//  DisclosureSection.swift
//  Harbour
//
//  Created by royal on 20/10/2021.
//

import SwiftUI

struct DisclosureSection<Content>: View where Content: View {
	let label: String
	@ViewBuilder let content: () -> Content
	
	var body: some View {
		DisclosureGroup(content: {
			VStack(spacing: 20, content: content)
				.padding(.top, .medium)
		}) {
			Text(label)
		}
	}
}