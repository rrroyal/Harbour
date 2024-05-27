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
	#if os(iOS)
	@Environment(SceneDelegate.self) private var sceneDelegate
	#elseif os(macOS)
	@State private var sceneDelegate = SceneDelegate()
	#endif
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel = ViewModel()

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
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.navigationTitle("SettingsView.Title")
			.toolbar {
				#if targetEnvironment(macCatalyst)
				ToolbarItem(placement: .destructiveAction) {
					CloseButton(style: .circleButton)
				}
				#endif
			}
		}
		.sheet(isPresented: $viewModel.isNegraSheetPresented) {
			NegraView()
		}
		.sheet(isPresented: $viewModel.isSetupSheetPresented) {
			viewModel.refreshServers()
		} content: {
			NavigationStack {
				SetupView()
					#if os(macOS)
					.addingCloseButton()
					#endif
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
	}
}

// MARK: - SettingsView+Actions

private extension SettingsView {
	@MainActor
	func handleError(_ error: Error, showIndicator: Bool) {
		sceneDelegate.handleError(error, showIndicator: false)
		viewModel.logger.error("\(error, privacy: .public)")

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
	SettingsView()
		.withEnvironment(appState: .shared)
		.environment(SceneDelegate())
}
