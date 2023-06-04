//
//  ContentView+PlaceholderView.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//

import SwiftUI

// MARK: - ContentView+PlaceholderView

extension ContentView {
	struct PlaceholderView: View {
		let viewState: ViewModel.ViewState

		var body: some View {
			Group {
				switch viewState {
				case .loading:
					ProgressView()
						.progressViewStyle(.circular)
				case .hasContainers:
					EmptyView()
				default:
					if let title = viewState.title {
						Text(title)
					}
				}
			}
			.foregroundStyle(.secondary)
			.transition(.opacity)
			.animation(.easeInOut, value: viewState)
		}
	}
}

// MARK: - Previews

struct ContentView_PlaceholderView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView.PlaceholderView(viewState: .loading)
		ContentView.PlaceholderView(viewState: .error(NSError(domain: "", code: 0, userInfo: nil)))
		ContentView.PlaceholderView(viewState: .hasContainers)
		ContentView.PlaceholderView(viewState: .containersEmpty)
		ContentView.PlaceholderView(viewState: .noEndpointSelected)
		ContentView.PlaceholderView(viewState: .noEndpoints)
		ContentView.PlaceholderView(viewState: .noServer)
		ContentView.PlaceholderView(viewState: .somethingWentWrong)
	}
}
