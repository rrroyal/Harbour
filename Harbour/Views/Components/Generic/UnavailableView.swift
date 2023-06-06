//
//  UnavailableView.swift
//  Harbour
//
//  Created by royal on 08/06/2023.
//

import SwiftUI

struct UnavailableView: View {
	private let title: String
	private let systemImage: String

	init(title: String, systemImage: String) {
		self.title = title
		self.systemImage = systemImage
	}

	init(state: ViewState) {
		self.title = state.title
		self.systemImage = state.icon
	}

	var body: some View {
		ContentUnavailableView(title, systemImage: systemImage)
	}
}

extension UnavailableView {
	private typealias Localization = Localizable.UnavailableView

	enum ViewState {
		/// View is being searched.
		case searchEmpty(query: String?)

		/// View has no content.
		case empty(title: String, icon: String?)

		var title: String {
			switch self {
			case .searchEmpty(let query):
				if let query {
					Localization.SearchEmpty.titleWithQuery(query)
				} else {
					Localization.SearchEmpty.title
				}
			case .empty(let title, _):
				title
			}
		}

		var icon: String {
			switch self {
			case .searchEmpty:
				SFSymbol.search
			case .empty(_, let icon):
				icon ?? SFSymbol.xmark
			}
		}
	}
}
