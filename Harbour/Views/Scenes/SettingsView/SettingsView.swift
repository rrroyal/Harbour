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
	@Environment(SceneState.self) private var sceneState
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@State private var viewModel = ViewModel()

	var body: some View {
		NavigationStack {
			Form {
				PortainerSection(viewModel: viewModel)
				GeneralSection(viewModel: viewModel)
				InterfaceSection(viewModel: viewModel)
				OtherSection(viewModel: viewModel)
			}
			.formStyle(.grouped)
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.navigationTitle("SettingsView.Title")
//			.toolbar {
//				#if os(macOS)
//				ToolbarItem(placement: .cancellationAction) {
//					CloseButton {
//						dismiss()
//					}
//				}
//				#endif
//			}
		}
		.sheet(isPresented: $viewModel.isNegraSheetPresented) {
			NegraView()
		}
		.sheet(isPresented: $viewModel.isSetupSheetPresented) {
			viewModel.refreshServers()
		} content: {
			SetupView()
		}
		.environment(\.showIndicator, sceneState.showIndicator)
		.indicatorOverlay(model: sceneState.indicators)
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
		.environmentObject(Preferences.shared)
}
