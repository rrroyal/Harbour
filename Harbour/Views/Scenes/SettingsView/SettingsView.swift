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
			List {
				PortainerSection(viewModel: viewModel)
				GeneralSection(viewModel: viewModel)
				InterfaceSection(viewModel: viewModel)
				OtherSection(viewModel: viewModel)
			}
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.navigationTitle("SettingsView.Title")
			.toolbar {
				#if targetEnvironment(macCatalyst)
				ToolbarItem(placement: .cancellationAction) {
					CloseButton {
//						Haptics.generateIfEnabled(.sheetPresentation)
						dismiss()
					}
				}
				#endif
			}
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
