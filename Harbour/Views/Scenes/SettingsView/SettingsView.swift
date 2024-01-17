//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

struct SettingsView: View {
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
//				#if os(macOS) || targetEnvironment(macCatalyst)
//				ToolbarItem(placement: .cancellationAction) {
//					CloseButton {
//						dismiss()
//					}
//				}
//				#endif
//			}
		}
		.sheet(isPresented: $viewModel.isNegraSheetPresented) {
			Text(verbatim: "🐕")
		}
	}
}

#Preview {
	SettingsView()
		.environmentObject(Preferences.shared)
}
