//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import IndicatorsKit
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
	static let id: String = "\(SettingsView.self)"

	#if os(iOS)
	@Environment(SceneDelegate.self) private var sceneDelegate
	#elseif os(macOS)
	@State private var sceneDelegate = SceneDelegate()
	#endif
	@Environment(PortainerStore.self) private var portainerStore
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel: ViewModel

	init(portainerStore: PortainerStore, appState: AppState) {
		_viewModel = State(initialValue: ViewModel(portainerStore: portainerStore, appState: appState))
	}

	var body: some View {
		NavigationStack {
			Form {
				ConnectionSection()
				PortainerSection()
				GeneralSection()
				InterfaceSection()
				OtherSection()
			}
			.formStyle(.grouped)
			.scrollPosition(id: $viewModel.scrollPosition)
			.scrollDismissesKeyboard(.interactively)
			.toggleStyle(.switch)
			.tint(.accentColor)
			.navigationTitle("SettingsView.Title")
			#if os(iOS)
			.addingCloseButton()
			#endif
		}
		.sheet(isPresented: $viewModel.isNegraSheetPresented) {
			NegraView()
				#if os(macOS)
				.sheetMinimumFrame()
				#endif
		}
		.sheet(isPresented: $viewModel.isSetupSheetPresented) {
			withAnimation {
				viewModel.refreshServers()
			}
		} content: {
			NavigationStack {
				SetupView(portainerStore: portainerStore)
					.addingCloseButton()
			}
			#if os(macOS)
			.sheetMinimumFrame()
			#endif
		}
		.environment(viewModel)
		#if os(macOS)
		.environment(sceneDelegate)
		#endif
		.environment(\.errorHandler, .init(handleError))
		.environment(\.presentIndicator, .init { indicator, _ in viewModel.presentIndicator(indicator) })
		.indicatorOverlay(model: viewModel.indicators, alignment: .top, insets: .init(top: 8, leading: 0, bottom: 0, trailing: 0))
		.onChange(of: viewModel.activeURL) { _, newURL in
			if let newURL {
				viewModel.presentIndicator(.serverSwitched(newURL))
			}
		}
	}
}

// MARK: - SettingsView+Actions

private extension SettingsView {
	@MainActor
	func handleError(_ error: Error, showIndicator: Bool) {
		sceneDelegate.handleError(error, showIndicator: false)
		viewModel.logger.error("\(error.localizedDescription, privacy: .public)")

		if showIndicator {
			viewModel.presentIndicator(.error(error))
		}
	}
}

// MARK: - SettingsView+NegraView

private extension SettingsView {
	struct NegraView: View {
		var body: some View {
			AsyncImage(url: URL(string: "https://shameful.xyz/media/Negra.jpeg")) { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} placeholder: {
				ProgressView()
			}
		}
	}
}

// MARK: - Previews

#Preview {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	let appState = AppState(portainerStore: portainerStore)
	SettingsView(portainerStore: portainerStore, appState: appState)
		.withEnvironment(appState: appState, preferences: preferences, portainerStore: portainerStore)
		.environment(SceneDelegate())
}
