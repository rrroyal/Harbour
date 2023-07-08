//
//  ContainerDetailsView+DetailsListView.swift
//  Harbour
//
//  Created by royal on 02/07/2023.
//

import SwiftUI

// MARK: - ContainerDetailsView+DetailsListView

extension ContainerDetailsView {
	struct DetailsListView<D: Identifiable, V: View>: View {
		let title: String
		let data: [D]
		let content: (D) -> V

		init(_ title: String, data: [D], content: @escaping (D) -> V) {
			self.title = title
			self.data = data
			self.content = content
		}

		var body: some View {
			List {
				ForEach(data, content: content)
			}
//			.background {
			.overlay {
				if data.isEmpty {
					ContentUnavailableView(Localizable.Generic.empty, systemImage: "ellipsis")
						.transition(.opacity)
						.allowsHitTesting(false)
				}
			}
			.navigationTitle(title)
			.animation(.easeInOut, value: data.isEmpty)
		}
	}
}

// MARK: - Previews

/*
#Preview {
	ContainerDetailsView.DetailsListView()
}
*/
