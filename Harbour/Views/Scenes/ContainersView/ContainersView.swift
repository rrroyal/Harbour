//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import PortainerKit
import SwiftUI

// MARK: - ContainersView

struct ContainersView: View {
	private typealias Localization = Localizable.ContainersView

	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.cvUseGrid) private var useGrid
	let containers: [Container]

	@ViewBuilder
	private var containersList: some View {
		if useGrid {
			ContainersGridView(containers: containers)
		} else {
			ContainersListView(containers: containers)
		}
	}

	var body: some View {
		containersList
			.padding(.horizontal)
			.padding(.bottom)
			.navigationDestination(for: ContainerNavigationItem.self) { navigationItem in
				ContainerDetailsView(navigationItem: navigationItem)
			}
			.transition(.opacity)
			.animation(.easeInOut, value: useGrid)
//			.animation(.easeInOut, value: containers)
//			.animation(.easeInOut, value: portainerStore.selectedEndpoint == nil)
//			.animation(.easeInOut, value: portainerStore.containers.isEmpty)
	}
}

// MARK: - ContainersView+NoContainersPlaceholder

extension ContainersView {
	struct NoContainersPlaceholder: View {
		let isEmpty: Bool

		var body: some View {
			VStack {
				if isEmpty {
					Text(Localization.noContainersPlaceholder)
						.foregroundStyle(.secondary)
						.padding()
						.transition(.opacity)
				}
			}
			.animation(.easeInOut, value: isEmpty)
		}
	}
}

// MARK: - ContainersView+ListModifier

extension ContainersView {
	struct ListModifier<BackgroundView: View>: ViewModifier {
		let background: () -> BackgroundView

		init(background: @escaping () -> BackgroundView) {
			self.background = background
		}

		@ViewBuilder
		private var backgroundView: some View {
			background()
				.containerRelativeFrame([.horizontal, .vertical])
				.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		}

		func body(content: Content) -> some View {
			content
				.background(backgroundView)
				.scrollDismissesKeyboard(.interactively)
		}
	}
}

// MARK: - Previews

#Preview {
	ContainersView(containers: [])
}
