//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 17/07/2022.
//

import SwiftUI
import PortainerKit
import IndicatorsKit
import CommonFoundation
import CommonHaptics

// MARK: - ContentView

struct ContentView: View {
	private typealias Localization = Localizable.ContentView

	@EnvironmentObject private var appDelegate: AppDelegate
	@EnvironmentObject private var sceneDelegate: SceneDelegate
	@EnvironmentObject private var appState: AppState
	@EnvironmentObject private var portainerStore: PortainerStore
	@EnvironmentObject private var preferences: Preferences

	@StateObject private var viewModel: ViewModel

	init() {
		let viewModel = ViewModel()
		self._viewModel = .init(wrappedValue: viewModel)
	}

	@ViewBuilder
	private var titleMenu: some View {
		ForEach(portainerStore.endpoints) { endpoint in
			Button(action: {
				Haptics.generateIfEnabled(.light)
				viewModel.selectEndpoint(endpoint)
			}) {
				let isSelected = portainerStore.selectedEndpoint?.id == endpoint.id
				Label(endpoint.name ?? endpoint.id.description, systemImage: isSelected ? SFSymbol.selected : "")
			}
		}
	}

	@ViewBuilder
	private var containersView: some View {
		ScrollView {
			// TODO: Hide summary when searching
			#if ENABLE_PREVIEW_FEATURES
			if preferences.cvDisplaySummary && viewModel.viewState == .hasContainers {
				// TODO: Summary
				Text("Summary")
				Divider()
			}
			#endif

			ContainersView(containers: viewModel.containers)
				.transition(.opacity)
				.animation(.easeInOut, value: viewModel.containers)
		}
		.refreshable(action: viewModel.refresh)
		.searchable(text: $viewModel.searchFilter, placement: .navigationBarDrawer)
		.scrollDismissesKeyboard(.interactively)
	}

	// MARK: body

	var body: some View {
		NavigationWrapped(useColumns: viewModel.shouldUseColumns, content: {
			containersView
				.background(PlaceholderView(viewState: viewModel.viewState))
				.background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
				.navigationTitle(viewModel.navigationTitle)
				.navigationBarTitleDisplayMode(.inline)
				.toolbarTitleMenu {
					titleMenu
				}
				.toolbar {
					ToolbarItem(placement: .primaryAction) {
						Button(action: {
//							Haptics.generateIfEnabled(.sheetPresentation)
							sceneDelegate.isSettingsSheetPresented.toggle()
						}) {
							Label(Localization.NavigationButton.settings, systemImage: SFSymbol.settings)
						}
					}

					#if ENABLE_PREVIEW_FEATURES
					ToolbarItem(placement: .navigationBarLeading) {
						NavigationLink(destination: {
							StacksView()
						}) {
							Label(Localization.NavigationButton.stacks, systemImage: SFSymbol.stack)
								.symbolVariant(portainerStore.isSetup ? .none : .slash)
						}
						.disabled(!portainerStore.isSetup)
					}
					#endif
				}
		}, placeholderContent: {
			Text(Localization.noContainerSelectedPlaceholder)
				.foregroundStyle(.tertiary)
		})
		.indicatorOverlay(model: sceneDelegate.indicators)
		.sheet(isPresented: $sceneDelegate.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $viewModel.isLandingSheetPresented, onDismiss: {
			viewModel.onLandingDismissed()
		}) {
			LandingView()
		}
		.environment(\.sceneErrorHandler, sceneDelegate.handleError)
		.environment(\.showIndicatorAction, sceneDelegate.showIndicator)
		.onOpenURL { url in
			sceneDelegate.onOpenURL(url)
		}
		.onContinueUserActivity(HarbourUserActivityIdentifier.containerDetails) { userActivity in
			sceneDelegate.onContinueContainerDetailsActivity(userActivity)
		}
	}
}

// MARK: - ContentView+Components

private extension ContentView {
	struct NavigationWrapped<Content: View, PlaceholderContent: View>: View {
		@EnvironmentObject private var sceneDelegate: SceneDelegate
		let useColumns: Bool
		let content: () -> Content
		let placeholderContent: () -> PlaceholderContent

		@ViewBuilder
		private var viewSplit: some View {
			NavigationSplitView(sidebar: {
				content()
			}) {
				placeholderContent()
			}
			.navigationSplitViewColumnWidth(min: 100, ideal: 200, max: .infinity)
		}

		@ViewBuilder
		private var viewStack: some View {
			NavigationStack(path: $sceneDelegate.navigationPath) {
				content()
			}
		}

		var body: some View {
			if useColumns {
				viewSplit
			} else {
				viewStack
			}
		}
	}
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(AppState.shared)
			.environmentObject(PortainerStore.shared)
			.environmentObject(Preferences.shared)
	}
}
